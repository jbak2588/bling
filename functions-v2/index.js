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
        logger.error(`❌ 오류: Firestore에서 ruleId '${ruleId}' 문서를 찾을 수 없습니다.`);
        return { success: false, error: "Invalid ruleId." };
      }
      const promptTemplate = ruleDoc.data().report_template_prompt;

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

      // New: 2.5 계열로 통일 + Responses API 미지원 환경 폴백
      const userContents = [{ role: "user", parts: [{ text: promptTemplate }, ...imageParts] }];
      let text = "";
      if (hasResponsesApi(genAI)) {
        try {
          const primary = await genAI.responses.generate({
            model: "gemini-2.5-flash",
            contents: userContents,
            safetySettings,
            responseMimeType: "application/json",
          });
          text = primary?.output_text || "";
        } catch (e) {
          if (isModelNotFoundError(e)) {
            const fb = await genAI.responses.generate({
              model: "gemini-2.5-pro",
              contents: userContents,
              safetySettings,
              responseMimeType: "application/json",
            });
            text = fb?.output_text || "";
          } else {
            throw e;
          }
        }
      } else {
        // 구 SDK: getGenerativeModel().generateContent 사용
        try {
          const model = genAI.getGenerativeModel({
            model: "gemini-2.5-flash",
            safetySettings,
            generationConfig: { responseMimeType: "application/json" },
          });
          const res = await model.generateContent({ contents: userContents });
          text = String(res?.response?.text?.() ?? "");
        } catch (e) {
          if (isModelNotFoundError(e)) {
            const fbModel = genAI.getGenerativeModel({
              model: "gemini-2.5-pro",
              safetySettings,
              generationConfig: { responseMimeType: "application/json" },
            });
            const res2 = await fbModel.generateContent({ contents: userContents });
            text = String(res2?.response?.text?.() ?? "");
          } else {
            throw e;
          }
        }
      }

      const jsonBlock = (text.match(/```json([\s\S]*?)```/i)?.[1] || text).trim();
      let prediction;
      try {
        prediction = JSON.parse(jsonBlock);
      } catch (e) {
        logger.error("❌ JSON parse failed for Gemini output", {
          output: text.slice(0, 500),
        });
        throw new HttpsError("data-loss", "AI returned invalid JSON.");
      }
      logger.info("✅ Gemini 분석 성공", {
        predicted_item_name: prediction?.predicted_item_name,
      });
      return { success: true, prediction: prediction?.predicted_item_name ?? null };

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

    // 전역 치환
    promptTemplate = (promptTemplate || "")
      .replace(/{{userPrice}}/g, String(userPrice ?? ""))
      .replace(/{{userDescription}}/g, String(userDescription ?? ""))
      .replace(/{{confirmedProductName}}/g, String(confirmedProductName ?? ""));

    // NOTE: 1.5 계열/별칭 제거, 2.5 계열로 통일
    const model = genAI.getGenerativeModel({
      model: "gemini-2.5-flash",
      safetySettings,
      generationConfig: { responseMimeType: "application/json" },
    });

    if (!Array.isArray(imageUrls.initial) || typeof imageUrls.guided !== "object") {
      throw new HttpsError("invalid-argument", "imageUrls must include initial[] and guided{}");
    }
    const allImageUrls = [...imageUrls.initial, ...Object.values(imageUrls.guided)];

    const ac = new AbortController();
    const to = setTimeout(() => ac.abort(), FETCH_TIMEOUT_MS);
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

    // New: responses.generate 미지원 환경 대비 generateContent 사용
    let jsonStr = "";
    try {
      const res = await model.generateContent({
        contents: [{ role: "user", parts: [{ text: promptTemplate }, ...imageParts] }],
      });
      jsonStr = String(res?.response?.text?.() ?? "").trim();
    } catch (e) {
      if (isModelNotFoundError(e)) {
        const fallbackModel = genAI.getGenerativeModel({
          model: "gemini-2.5-pro",
          safetySettings,
          generationConfig: { responseMimeType: "application/json" },
        });
        const res2 = await fallbackModel.generateContent({
          contents: [{ role: "user", parts: [{ text: promptTemplate }, ...imageParts] }],
        });
        jsonStr = String(res2?.response?.text?.() ?? "").trim();
      } else {
        throw e;
      }
    }

    const jsonBlock = (jsonStr.match(/```json([\s\S]*?)```/i)?.[1] || jsonStr).trim();
    let report;
    try {
      report = JSON.parse(jsonBlock);
    } catch (e) {
      logger.error("❌ JSON parse failed for final report", {
        output: jsonStr.slice(0, 500),
      });
      throw new HttpsError("data-loss", "AI final report JSON invalid.");
    }
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
