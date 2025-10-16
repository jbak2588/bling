/**
 * =======================[ Server/Client 책임 경계 최종 검수 메모 ]=======================
 * 대상 파일 : functions-v2/index.js (최신본)
 * 목적     : "범용 중고물품 AI 검수" 서버 코드로서의 적합성 점검 및
 *            Flutter(클라이언트)로 위임해야 할 기능 명시. (코드 변경 없음)
 *
 * ■ 서버(이 파일)가 맡는 범위 — 유지 대상
 *   1) 보안/검증:
 *      - App Check/인증 강제(enforceAppCheck, auth 확인)
 *      - 입력 유효성 검증(ruleId 존재, 이미지 URL 배열 형식)
 *      - 이미지 다운로드/크기 제한(HTTPS만 허용, 7.5MB 제한)
 *   2) 규칙/프롬프트 관리:
 *      - Firestore의 ai_verification_rules/{ruleId}에서 프롬프트 템플릿 로드
 *      - ruleId만으로 다양한 카테고리·템플릿을 처리(범용성 유지)
 *   3) 모델 호출/파싱:
 *      - Gemini 호출(2.5 계열), 안전설정 적용
 *      - 응답(JSON)만 엄격 파싱, 핵심 필드만 추출
 *      - 공통 오류 매핑(HttpsError) 및 진단 로그 기록(원문 스니펫/파싱 키)
 *   4) 중립 응답 계약:
 *      - initialproductanalysis → { success, prediction }  (prediction: string|null)
 *      - generatefinalreport   → { success, report }       (report: object)
 *      - UI 문구/카테고리 매핑/브랜드 규칙 등은 포함하지 않음 (범용성 보존)
 *
 * ■ Flutter(클라이언트)가 맡아야 할 범위 — 서버 밖으로 위임
 *   1) 화면/UX:
 *      - 카테고리 선택/촬영 가이드/갤러리 업로드 흐름
 *      - "예상 상품명(없음)" 등 UI 문구 표시, 재시도·수정 입력 UX
 *   2) 데이터 준비/전송:
 *      - 이미지 업로드(Storage) 후 HTTPS URL 전달
 *      - 어떤 ruleId를 쓸지 선택(카테고리와 규칙 매핑)
 *      - userPrice/userDescription/confirmedProductName 등 최종 보고서에 필요한 값 전달
 *   3) 후처리·매핑:
 *      - predicted_category_id → 앱 내부 카테고리 매핑
 *      - prediction이 비었을 때의 대체 경로(수기 입력/재시도) 결정
 *   4) 상태 동기화:
 *      - UI 단계 전환(초기분석 → 사용자확정 → 최종보고서)
 *      - 필요 시 클라이언트측 로컬 로깅/분석 이벤트 전송
 *
 * ■ 요청/응답 데이터 계약(요약)
 *   - initialproductanalysis (onCall)
 *     req: { imageUrls: string[], ruleId: string }
 *     res: { success: boolean, prediction: string|null }
 *
 *   - generatefinalreport (onCall)
 *     req: {
 *       imageUrls: { initial: string[], guided: Record<string,string> },
 *       ruleId: string,
 *       confirmedProductName?: string,
 *       userPrice?: number|string,
 *       userDescription?: string
 *     }
 *     res: { success: boolean, report: object }
 *
 * ⓘ 결론: 현 index.js는 서버-클라이언트 역할 분리가 준수된 "범용" 구조이며,
 *         제품군 특화 로직/문구는 포함하지 않습니다. Flutter 측에서 UX/매핑을 담당하세요.
 * ===========================================================================================
 */
/**
 * ============================================================================
 * Bling DocHeader (v3.1 - Gemini Safety Settings)
 * Module        : Auth, Trust, AI Verification
 * File          : functions-v2/index.js
 * Purpose       : 사용자 신뢰도 계산 및 Gemini 기반의 AI 상품 분석을 처리합니다.
 * Triggers      : Firestore onUpdate `users/{userId}`, HTTPS onCall
 * ============================================================================
 */
const { onCall, HttpsError } = require("firebase-functions/v2/https");
const { onDocumentUpdated } = require("firebase-functions/v2/firestore");
const { initializeApp } = require("firebase-admin/app");
const { defineSecret } = require("firebase-functions/params");
const { getFirestore } = require("firebase-admin/firestore");
const { logger } = require("firebase-functions");
const {
  GoogleGenerativeAI,
  HarmCategory,
  HarmBlockThreshold,
} = require("@google/generative-ai");

initializeApp();

// 🔐 Secrets 선언: 배포/런타임에서 안전하게 주입
const GEMINI_KEY = defineSecret("GEMINI_KEY");

// ──────────────────────────────────────────────────────────────────────────────
// 요청 타임아웃/재시도 설정 (Gemini 전용)
// ──────────────────────────────────────────────────────────────────────────────
// [수정] Gemini 서버의 극심한 지연에 대응하기 위해 개별 요청 타임아웃을 60초로 늘립니다.
const GENAI_TIMEOUT_MS = 60_000;         // 60s: 개별 Gemini 요청 타임아웃
const GENAI_MAX_RETRIES = 2;             // 총 3회(최초 + 2회 재시도)
const GENAI_BASE_DELAY_MS = 800;         // 첫 백오프 지연

// ──────────────────────────────────────────────────────────────────────────────
// Debug/Tracing helpers for AI response diagnostics
// ──────────────────────────────────────────────────────────────────────────────
const RAW_LOG_LIMIT = 1200; // 로그에 남길 최대 원문 길이
/**
 * 모델이 가끔 ```json 코드블럭으로 감싸거나, 앞뒤에 잡담을 붙이는 경우가 있어
 * 가능한 한 JSON 본문만 뽑아 파싱을 시도한다.
 */
function extractJsonText(raw) {
  if (!raw) return "";
  const m = raw.match(/```json([\s\S]*?)```/i);
  return (m ? m[1] : raw).trim();
}
function tryParseJson(text) {
  try { return JSON.parse(text); } catch { return null; }
}
/**
 * 분석용 진단 로그: 원문 스니펫 + 파싱된 키 + 핵심 필드 유무
 */
function logAiDiagnostics(ctx, rawText, parsed) {
  try {
    logger.info("🧪 AI raw snippet", {
      ctx,
      length: (rawText || "").length,
      snippet: String(rawText || "").slice(0, RAW_LOG_LIMIT),
    });
    if (parsed && typeof parsed === "object") {
      logger.info("🧪 AI parsed keys", {
        ctx,
        keys: Object.keys(parsed),
        has_predicted_item_name: Object.prototype.hasOwnProperty.call(parsed, "predicted_item_name"),
        predicted_item_name: parsed?.predicted_item_name ?? null,
        confidence: parsed?.confidence ?? null,
      });
    } else {
      logger.warn("🧪 AI parse failed (no valid JSON object)", { ctx });
    }
  } catch (e) {
    logger.warn("🧪 AI diagnostics logging error", { ctx, err: e?.toString?.() || e });
  }
}

// 런타임 시점에서만 키를 읽어 클라이언트 생성
const getGenAI = () => {
  const key = GEMINI_KEY.value();
  if (!key) {
    throw new HttpsError("failed-precondition", "GEMINI_KEY is not configured.");
  }
  return new GoogleGenerativeAI(key);
};

// 공통 onCall 옵션
const CALL_OPTS = {
  region: "us-central1",
  enforceAppCheck: true,
  memory: "1GiB",
  // 장시간 이미지 다운로드 + 모델 혼잡 대비
  timeoutSeconds: 300,
  secrets: [GEMINI_KEY],
};

// 이미지 다운로드 공통 제한
const MAX_IMAGE_BYTES = 7_500_000; // 7.5MB 안전선
const FETCH_TIMEOUT_MS = 45000; // 45s (네트워크/Storage 지연 대비)

// Treat Gemini model resolution issues as "not found" to allow graceful fallback.
function isModelNotFoundError(err) {
  try {
    const msg = (err && (err.message || (err.toString && err.toString()))) || "";
    return /404|Not Found|models\/.+? is not found|is not supported for generateContent/i.test(msg);
  } catch {
    return false;
  }
}

// SDK 호환 보조: Responses API 지원 여부 체크
function hasResponsesApi(genAI) {
  return !!(genAI && genAI.responses && typeof genAI.responses.generate === "function");
}

// 재시도 가능한 오류인지 판별
function isRetryable(err) {
  const s = (err && (err.status || err.code)) || 0;
  const msg = (err && (err.message || (err.toString && err.toString()))) || "";
  if ([408, 429, 500, 502, 503, 504].includes(Number(s))) return true;
  if (/timeout|timed out|unavailable|try again/i.test(msg)) return true;
  return false;
}

// 지정 ms 뒤 reject되는 타임아웃 Promise
function timeoutPromise(ms, tag = "genai") {
  return new Promise((_, rej) =>
    setTimeout(() => rej(new Error(`[${tag}] request timeout ${ms}ms`)), ms)
  );
}

// 지수 백오프 재시도 래퍼
async function withRetry(fn, { maxRetries = GENAI_MAX_RETRIES, baseDelay = GENAI_BASE_DELAY_MS, tag = "genai" } = {}) {
  let attempt = 0;
  let delay = baseDelay;
  while (true) {
    try {
      const started = Date.now();
      const result = await Promise.race([fn(), timeoutPromise(GENAI_TIMEOUT_MS, tag)]);
      logger.info("⏱️ GenAI latency", { tag, attempt: attempt + 1, ms: Date.now() - started });
      return result;
    } catch (e) {
      const retriable = isRetryable(e);
      logger.warn("↻ GenAI attempt failed", { tag, attempt: attempt + 1, retriable, err: e?.toString?.() || e });
      if (attempt >= maxRetries || !retriable) throw e;
      const jitter = Math.floor(Math.random() * 200);
      await new Promise((r) => setTimeout(r, delay + jitter));
      delay *= 2;
      attempt += 1;
    }
  }
}

// SDK 버전별 호출을 감싸는 통합 함수
async function genAiCall(genAI, { modelPrimary = "gemini-2.5-flash", modelFallback = "gemini-2.5-pro", contents, safetySettings, responseMimeType = "application/json", tag }) {
  if (hasResponsesApi(genAI)) {
    return withRetry(
      async () => {
        try {
          const resp = await genAI.responses.generate({
            model: modelPrimary,
            contents,
            safetySettings,
            responseMimeType,
          });
          return resp?.output_text || "";
        } catch (e) {
          // [수정] 모델을 찾을 수 없거나, 과부하 등 재시도 가능한 에러 발생 시 fallback 모델을 사용하도록 로직 강화
          const shouldUseFallback = isModelNotFoundError(e) || isRetryable(e);
          if (shouldUseFallback) {
            logger.warn(`⚠️ Primary model failed (${e.message}). Falling back to ${modelFallback}...`, { tag });
            const fb = await genAI.responses.generate({
              model: modelFallback,
              contents,
              safetySettings,
              responseMimeType,
            });
            return fb?.output_text || "";
          }
          throw e;
        }
      },
      { tag }
    );
  }
  return withRetry(
    async () => {
      try {
        const m = genAI.getGenerativeModel({
          model: modelPrimary,
          safetySettings,
          generationConfig: { responseMimeType },
        });
        const r = await m.generateContent({ contents });
        return String(r?.response?.text?.() ?? "");
      } catch (e) {
        // [수정] 동일한 fallback 로직을 다른 SDK 버전 호출에도 적용
        const shouldUseFallback = isModelNotFoundError(e) || isRetryable(e);
        if (shouldUseFallback) {
          logger.warn(`⚠️ Primary model failed (${e.message}). Falling back to ${modelFallback}...`, { tag });
          const fm = genAI.getGenerativeModel({
            model: modelFallback,
            safetySettings,
            generationConfig: { responseMimeType },
          });
          const r2 = await fm.generateContent({ contents });
          return String(r2?.response?.text?.() ?? "");
        }
        throw e;
      }
    },
    { tag }
  );
}

/**
 * [유지] 사용자 문서가 업데이트될 때 신뢰도 점수와 레벨을 다시 계산합니다.
 */
exports.calculateTrustScore = onDocumentUpdated(
  {
    document: "users/{userId}",
    region: "us-central1",
  },
  async (event) => {
    const userData = event.data.after.data();
    const previousUserData = event.data.before.data();
    const userId = event.params.userId;

    if (!userData) {
      logger.info(`User data for ${userId} is missing.`);
      return null;
    }

    const mainFieldsUnchanged =
      previousUserData &&
      userData.thanksReceived === previousUserData.thanksReceived &&
      userData.reportCount === previousUserData.reportCount &&
      userData.profileCompleted === previousUserData.profileCompleted &&
      userData.phoneNumber === previousUserData.phoneNumber &&
      JSON.stringify(userData.locationParts) ===
        JSON.stringify(previousUserData.locationParts);

    if (mainFieldsUnchanged) {
      logger.info(`No score-related changes for user ${userId}, exiting.`);
      return null;
    }

    let score = 0;
    if (userData.locationParts && userData.locationParts.kel) score += 50;
    if (userData.locationParts && userData.locationParts.rt) score += 50;
    if (userData.phoneNumber && userData.phoneNumber.length > 0) score += 100;
    if (userData.profileCompleted === true) score += 50;

    const thanksCount = userData.thanksReceived || 0;
    score += thanksCount * 10;

    const reportCount = userData.reportCount || 0;
    score -= reportCount * 50;

    const finalScore = Math.max(0, score);

    let level = "normal";
    if (finalScore > 500) {
      level = "trusted";
    } else if (finalScore > 100) {
      level = "verified";
    }

    if (finalScore !== userData.trustScore || level !== userData.trustLevel) {
      logger.info(
        `Updating user ${userId} score to ${finalScore} and level to ${level}`
      );
      return event.data.after.ref.update({
        trustScore: finalScore,
        trustLevel: level,
      });
    } else {
      logger.info(`Score and level for user ${userId} remain unchanged.`);
      return null;
    }
  }
);

/**
 * [수정] 1차 갤러리 이미지들을 기반으로 상품명을 예측합니다. (안전 설정 추가)
 */
exports.initialproductanalysis = onCall(
  CALL_OPTS,
  async (request) => {
    const genAI = getGenAI();

    logger.info("✅ initialproductanalysis 함수가 호출되었습니다.", {
      auth: request.auth,
      uid: request.auth ? request.auth.uid : "No UID",
      body: request.data,
    });

    if (!request.auth) {
      logger.error("❌ 치명적 오류: request.auth 객체가 없습니다. 비로그인 사용자의 호출로 간주됩니다.");
      throw new HttpsError("unauthenticated", "The function must be called while authenticated.");
    }

    try {
      const { imageUrls, ruleId } = request.data || {};
      if (!Array.isArray(imageUrls) || imageUrls.length === 0 || !ruleId) {
        logger.error("❌ 오류: 이미지 URL 또는 ruleId가 누락되었습니다.");
        throw new HttpsError("invalid-argument", "Image URLs (array) and ruleId are required.");
      }

      const db = getFirestore();
      const ruleDoc = await db.collection("ai_verification_rules").doc(ruleId).get();
      if (!ruleDoc.exists) {
        // [수정] onCall 함수에서는 HttpsError를 throw하여 클라이언트에 일관된 오류를 전달하는 것이 표준입니다.
        throw new HttpsError("not-found", `Rule with ID ${ruleId} not found.`);
      }
      // [수정] 데이터베이스 필드 불일치에 대응하기 위한 방어 코드
      // initial_analysis_prompt_template 필드를 우선 사용하고, 없으면 report_template_prompt를 사용합니다. (하위 호환성)
      const ruleData = ruleDoc.data();
      const promptTemplate =
        ruleData.initial_analysis_prompt_template || ruleData.report_template_prompt;
      if (!promptTemplate) {
        throw new HttpsError("failed-precondition", `Rule '${ruleId}' is missing a valid prompt template.`);
      }

      const ac = new AbortController();
      const to = setTimeout(() => ac.abort(), FETCH_TIMEOUT_MS);
      const imageParts = await Promise.all(
        imageUrls.map(async (url) => {
          if (!/^https:\/\//i.test(url)) {
            throw new HttpsError("invalid-argument", "Only https image URLs are allowed.");
          }
          let response;
          try {
            response = await fetch(url, { signal: ac.signal });
          } catch (e) {
            if (e && e.name === "AbortError") throw new HttpsError("deadline-exceeded", "Image fetch timed out.");
            throw e;
          }
          if (!response.ok) {
            throw new HttpsError("not-found", `Failed to fetch image: ${response.status}`);
          }
          const len = Number(response.headers.get("content-length") || 0);
          if (len && len > MAX_IMAGE_BYTES) {
            throw new HttpsError("resource-exhausted", "Image too large (>7.5MB).");
          }
          const buffer = Buffer.from(await response.arrayBuffer());
          if (!len && buffer.length > MAX_IMAGE_BYTES) {
            throw new HttpsError("resource-exhausted", "Image too large (>7.5MB).");
          }
          return {
            inlineData: {
              mimeType: response.headers.get("content-type") || "image/jpeg",
              data: buffer.toString("base64"),
            },
          };
        })
      );
      clearTimeout(to);

      // 2.5 계열 고정 호출 + 재시도/타임아웃 래퍼 사용
      const userContents = [{ role: "user", parts: [{ text: promptTemplate }, ...imageParts] }];
      const text = await genAiCall(genAI, {
        modelPrimary: "gemini-2.5-flash",
        modelFallback: "gemini-2.5-pro",
        contents: userContents,
        safetySettings,
        responseMimeType: "application/json",
        tag: "initialproductanalysis",
      });

      // 진단 로그용 원문/파싱 결과 기록
      const jsonText = extractJsonText(text);
      const prediction = tryParseJson(jsonText);
      logAiDiagnostics("initialproductanalysis", text, prediction);
      if (!prediction) {
        throw new HttpsError("data-loss", "AI returned invalid JSON.");
      }
      const predictedName = prediction?.predicted_item_name ?? null;
      if (!predictedName || (typeof predictedName === "string" && predictedName.trim() === "")) {
        logger.warn("⚠️ AI returned empty 'predicted_item_name'", {
          ctx: "initialproductanalysis",
          hasKeys: Object.keys(prediction || {}),
        });
      } else {
        logger.info("✅ Gemini 분석 성공", { predicted_item_name: predictedName });
      }
      return { success: true, prediction: predictedName };

    } catch (error) {
      logger.error("❌ initialproductanalysis 함수 내부에서 심각한 오류 발생:", error);
      if (error instanceof HttpsError) throw error;
      // Gemini/네트워크 예외 메시지를 그대로 남기되, 상태 코드는 명확히
      const msg = (error && (error.message || error.toString && error.toString())) || "Unknown";
      // SDK의 rate-limit/availability는 'unavailable'로 매핑
      if (/quota|rate|unavailable|temporarily/i.test(msg)) {
        throw new HttpsError("unavailable", "AI service temporarily unavailable.");
      }
      throw new HttpsError("internal", "An internal error occurred.");
    }
  }
);

/**
 * [수정] 모든 이미지와 정보를 종합하여 최종 판매 보고서를 생성합니다. (안전 설정 추가)
 */
exports.generatefinalreport = onCall(CALL_OPTS, async (request) => {
  const genAI = getGenAI();

  const {
    imageUrls,
    ruleId,
    confirmedProductName,
    userPrice,
    userDescription,
  } = request.data;

  if (!imageUrls || !ruleId) {
    throw new HttpsError("invalid-argument", "Required data is missing.");
  }

  try {
    const db = getFirestore();
    const ruleDoc = await db.collection("ai_verification_rules").doc(ruleId).get();
    if (!ruleDoc.exists) {
      throw new HttpsError("not-found", "Verification rule not found.");
    }
    let promptTemplate = ruleDoc.data().report_template_prompt;

    // [추적 코드 1] 프롬프트 템플릿 누락 방지
    if (!promptTemplate) {
      logger.error(`❌ Rule '${ruleId}' is missing the 'report_template_prompt' field.`);
      throw new HttpsError("failed-precondition", `Rule '${ruleId}' is not configured for final report.`);
    }

    // 전역 치환
    promptTemplate = (promptTemplate || "")
      .replace(/{{userPrice}}/g, String(userPrice ?? ""))
      .replace(/{{userDescription}}/g, String(userDescription ?? ""))
      .replace(/{{confirmedProductName}}/g, String(confirmedProductName ?? ""));

    // ... (이미지 처리 로직은 동일)
    const allImageUrls = [...imageUrls.initial, ...Object.values(imageUrls.guided)];

    const ac = new AbortController();
    const to = setTimeout(() => ac.abort(), FETCH_TIMEOUT_MS);

    // ... (이미지 처리 로직은 동일)
    const imageParts = await Promise.all(
      allImageUrls.map(async (url) => {
        if (!/^https:\/\//i.test(url)) {
          throw new HttpsError("invalid-argument", "Only https image URLs are allowed.");
        }
        let response;
        try {
          response = await fetch(url, { signal: ac.signal });
        } catch (e) {
          if (e && e.name === "AbortError") throw new HttpsError("deadline-exceeded", "Image fetch timed out.");
          throw e;
        }
        if (!response.ok) {
          throw new HttpsError("not-found", `Failed to fetch image: ${response.status}`);
        }
        const len = Number(response.headers.get("content-length") || 0);
        if (len && len > MAX_IMAGE_BYTES) {
          throw new HttpsError("resource-exhausted", "Image too large (>7.5MB).");
        }
        const buffer = Buffer.from(await response.arrayBuffer());
        if (!len && buffer.length > MAX_IMAGE_BYTES) {
          throw new HttpsError("resource-exhausted", "Image too large (>7.5MB).");
        }
        return {
          inlineData: {
            mimeType: response.headers.get("content-type") || "image/jpeg",
            data: buffer.toString("base64"),
          },
        };
      })
    );
    clearTimeout(to);

    const jsonStr = (await genAiCall(genAI, {
      modelPrimary: "gemini-2.5-flash",
      modelFallback: "gemini-2.5-pro",
      contents: [{ role: "user", parts: [{ text: promptTemplate }, ...imageParts] }],
      safetySettings,
      responseMimeType: "application/json",
      tag: "generatefinalreport",
    })).trim();

    const jsonBlock = extractJsonText(jsonStr);
    const report = tryParseJson(jsonBlock);
    logAiDiagnostics("generatefinalreport", jsonStr, report);
    if (!report) {
      throw new HttpsError("data-loss", "AI returned invalid JSON for the final report.");
    }

    // [최종 수정] 클라이언트(Flutter) 코드와 데이터 키 이름을 일치시킵니다.
    // AI는 'suggested_price'를 반환하지만, Flutter 코드는 'price_suggestion'을 기대하고 있습니다.
    // 서버에서 키 이름을 변경하여 클라이언트로 보내기 전에 데이터 구조를 맞춰줍니다.
    if (report.suggested_price !== undefined) {
      report.price_suggestion = report.suggested_price;
      delete report.suggested_price;
    }

    // [추적 코드 2] 성공 직전 최종 로그
    logger.info("✅ Final report generated successfully. Preparing to return.", { reportObjectKeys: Object.keys(report) });

    // [최종 추적 코드] 객체를 문자열로 변환(직렬화)하는 과정에서 오류가 발생하는지 명시적으로 확인합니다.
    try {
      const reportString = JSON.stringify(report);
      logger.info(`✅ Report object successfully serialized. Length: ${reportString.length}. Returning to client.`);
    } catch (serializationError) {
      // 만약 여기서 에러가 발생하면, Gemini가 보낸 report 객체에 문제가 있는 것입니다.
      logger.error("❌ CRITICAL: Failed to serialize the report object.", {
        error: serializationError.toString(),
        reportObjectKeys: Object.keys(report),
      });
      // 직렬화 실패는 복구 불가능하므로, 명확한 에러를 던집니다.
      throw new HttpsError("internal", "Failed to process the AI report due to a serialization error.");
    }

    // [최종 복원] 진단용 임시 코드를 삭제하고, 실제 AI 리포트를 반환하는 원래 코드를 활성화합니다.
    return { success: true, report };

  } catch (error) {
    logger.error("Final report generation failed:", error?.toString?.() || error);
    if (error instanceof HttpsError) throw error;
    const msg = (error && (error.message || error.toString && error.toString())) || "Unknown";
    if (/quota|rate|unavailable|temporarily/i.test(msg)) {
      throw new HttpsError("unavailable", "AI final report temporarily unavailable.");
    }
    throw new HttpsError("internal", "AI final report generation failed.");
  }
});

// [업데이트] Gemini 안전 설정 (최신 카테고리 명칭 사용)
// 허용 카테고리: DANGEROUS_CONTENT, HARASSMENT, HATE_SPEECH, SEXUALLY_EXPLICIT, CIVIC_INTEGRITY
const safetySettings = [
  { category: HarmCategory.HARM_CATEGORY_DANGEROUS_CONTENT, threshold: HarmBlockThreshold.BLOCK_NONE },
  { category: HarmCategory.HARM_CATEGORY_HARASSMENT,        threshold: HarmBlockThreshold.BLOCK_MEDIUM_AND_ABOVE },
  { category: HarmCategory.HARM_CATEGORY_HATE_SPEECH,       threshold: HarmBlockThreshold.BLOCK_MEDIUM_AND_ABOVE },
  { category: HarmCategory.HARM_CATEGORY_SEXUALLY_EXPLICIT, threshold: HarmBlockThreshold.BLOCK_MEDIUM_AND_ABOVE },
  { category: HarmCategory.HARM_CATEGORY_CIVIC_INTEGRITY,   threshold: HarmBlockThreshold.BLOCK_MEDIUM_AND_ABOVE },
];
