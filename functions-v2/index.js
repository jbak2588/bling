/**
 * ============================================================================
 * Bling DocHeader (V3 Generic AI Verification, 2025-11-17)
 * Module        : Auth, Trust, AI Verification, Push, Boards, FindFriends
 * File          : functions-v2/index.js
 * Purpose       : Bling Cloud Functions 진입점.
 *                 - 사용자 신뢰도 계산
 *                 - 푸시 구독/알림
 *                 - 동네 게시판/친구찾기 한도
 *                 - Gemini 기반 범용 중고물품 AI 검수·인수
 * Region        : asia-southeast2 (Jakarta)
 * ============================================================================
 * [AI Verification V3 요약]
 * 1) initialproductanalysis (1차 분석)
 *    - 입력: { imageUrls[], locale, categoryName?, subCategoryName?, userDescription?, confirmedProductName? }
 *    - 출력: { success, prediction, suggestedShots[] }
 *    - 역할:
 *      • 등록자가 올린 텍스트+이미지를 보고 “예상 상품명(prediction)”을 추정
 *      • 동일 상품·카테고리에 관계없이, 구매자 신뢰 확보에 도움이 되는 추가 촬영 샷(suggestedShots)을
 *        3~5개 제안 (스마트폰/전자기기·패션·가구 등 모든 중고 카테고리 공용)
 *
 * 2) generatefinalreport (최종 AI 검수 리포트)
 *    - V3 단일 스키마(JSON)로 리포트를 생성:
 *      {
 *        version, modelUsed, trustVerdict,
 *        itemSummary, condition, priceAssessment,
 *        notesForBuyer, verificationSummary,
 *        onSiteVerificationChecklist
 *      }
 *    - “특정 모델명/버전/날짜가 존재하지 않는다”는 식의 단정을 금지하고,
 *      확신이 80% 미만인 항목은 해당 필드를 null 로 두고
 *      notesForBuyer / verificationSummary 로 “추가 확인 필요”만 안내하도록 설계.
 *
 * 3) enhanceProductWithAi
 *    - 기존 상품(productId)에 대해 evidenceImageUrls 를 추가로 받아
 *      V3 엔진을 다시 돌린 후:
 *        • aiReport (V3 JSON)
 *        • isAiVerified: true
 *        • aiVerificationStatus: "verified"
 *      를 products 문서에 저장.
 *
 * 4) verifyProductOnSite (AI 인수 2단계: 현장 동일성 검증)
 *    - 입력: { productId, newImageUrls[], locale? }
 *    - 원본 상품 이미지/리포트 + 구매자가 현장에서 촬영한 새 이미지를 비교하여
 *      {
 *        match: true | false | null,
 *        reason: string,
 *        discrepancies?: string[]
 *      }
 *      를 반환.
 *    - 주요 가드레일:
 *      • 실제 세계의 “공식 모델/버전/날짜 카탈로그”를 갖고 있다는 가정을 금지.
 *      • A/B 양쪽 사진이 똑같이 “이상한 버전/날짜/코드”를 보여주면
 *        → 시각적으로 같은 물건으로 보고 match=true 가능
 *        → 다만 discrepancies/notes 로 “이상한 값이니 현장에서 추가 확인 필요” 정도만 권고.
 *      • 정말로 다른 물건(전혀 다른 외관·색상·로고·식별자·심각한 신규 파손 등)이 보일 때만 match=false.
 *      • 사진이 너무 흐리거나, 체크리스트를 충족하지 못하면 match=null 로 처리해
 *        클라이언트에서 “AI 재시도 / 사진 다시 찍기” UX를 제공.
 *
 * [Gemini 인프라 / 안전 설정]
 *  - 모델:
 *      • 기본: gemini-2.5-flash
 *      • 실패/과부하 시: gemini-2.5-pro 로 자동 폴백
 *    → genAiCall + withRetry 로 통합, 60초 타임아웃/지수 백오프 재시도 지원.
 *  - 응답 처리:
 *      • responseMimeType="application/json" 강제
 *      • extractJsonText/tryParseJson/logAiDiagnostics 로
 *        코드블럭/잡담이 섞인 응답도 최대한 복구 후 키 존재 여부를 로깅.
 *      • 파싱 실패 시엔 data-loss HttpsError 또는 안전한 fallback JSON 으로 처리.
 *  - safetySettings:
 *      • DANGEROUS_CONTENT: BLOCK_NONE
 *      • HARASSMENT / HATE / SEXUALLY_EXPLICIT / CIVIC_INTEGRITY:
 *          BLOCK_MEDIUM_AND_ABOVE
 *
 * [비 AI 모듈 (기존 동작 유지)]
 *  - calculateTrustScore       : users/{userId} onUpdate, trustScore/trustLevel 계산
 *  - onUserPushPrefsWrite      : users.pushPrefs → FCM topic 구독/해지 동기화
 *  - onLocalNewsPostCreate     : posts → boards/{kel_key} metrics & hasGroupChat 플래그
 *  - startFriendChat           : Find Friends 일일 신규 채팅 한도 관리
 *  - onProductStatusPending    : AI pending 상품 → 관리자 + 판매자 알림(Firebase Messaging + notifications 서브컬렉션)
 *  - onProductStatusResolved   : pending → selling/rejected 시 판매자에게 최종 결과 알림
 * ============================================================================
 */

// (파일 내용...)
const { onCall, HttpsError } = require("firebase-functions/v2/https");
const { onDocumentUpdated, onDocumentCreated } = require("firebase-functions/v2/firestore");
// [Fix] 모든 함수의 기본 리전을 'asia-southeast2'에서 'asia-southeast2'(자카르타)로 변경
// (사용자 지연 시간 최소화 및 Firestore 데이터 전송 비용(Egress) 제거 목적)
const { setGlobalOptions } = require("firebase-functions/v2");
setGlobalOptions({ region: "asia-southeast2" });
const { initializeApp } = require("firebase-admin/app");
const { getMessaging } = require("firebase-admin/messaging"); // ✅ [푸시 스키마] 추가
const { defineSecret } = require("firebase-functions/params");
const { getFirestore, FieldValue } = require("firebase-admin/firestore");
const { logger } = require("firebase-functions");
const {
  GoogleGenerativeAI,
  HarmCategory,
  HarmBlockThreshold,
} = require("@google/generative-ai");

initializeApp();

// functions-v2/index.js (추가)
// [V3 REFACTOR] 'AI 룰 엔진'의 핵심인 categories_sync.js 의존성을 제거합니다.
// Object.assign(exports, require('./categories_sync'));

// 🔐 Secrets 선언: 배포/런타임에서 안전하게 주입
const GEMINI_KEY = defineSecret("GEMINI_KEY");

// ──────────────────────────────────────────────────────────────────────────────
// 요청 타임아웃/재시도 설정 (Gemini 전용)
// ──────────────────────────────────────────────────────────────────────────────
// [수정] Gemini 서버의 극심한 지연에 대응하기 위해 개별 요청 타임아웃을 60초로 늘립니다.
const GENAI_TIMEOUT_MS = 60_000; // 60s: 개별 Gemini 요청 타임아웃
const GENAI_MAX_RETRIES = 2; // 총 3회(최초 + 2회 재시도)
const GENAI_BASE_DELAY_MS = 800; // 첫 백오프 지연

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
  try {
    return JSON.parse(text);
  } catch {
    return null;
  }
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
        has_predicted_item_name: Object.prototype.hasOwnProperty.call(
          parsed,
          "predicted_item_name"
        ),
        predicted_item_name: parsed?.predicted_item_name ?? null,
        confidence: parsed?.confidence ?? null,
      });
    } else {
      logger.warn("🧪 AI parse failed (no valid JSON object)", { ctx });
    }
  } catch (e) {
    logger.warn("🧪 AI diagnostics logging error", {
      ctx,
      err: e?.toString?.() || e,
    });
  }
}

// 런타임 시점에서만 키를 읽어 클라이언트 생성
const getGenAI = () => {
  const key = GEMINI_KEY.value();
  if (!key) {
    throw new HttpsError(
      "failed-precondition",
      "GEMINI_KEY is not configured."
    );
  }
  return new GoogleGenerativeAI(key);
};
  /**
   * ============================================================================
   * [V3 NEW] AI 검증으로 'pending' 상태가 된 상품 알림 (Task 79)
   * 'products' 문서의 status가 'pending'으로 변경될 때 트리거됩니다.
   * 1. 관리자 그룹에게 알림을 보냅니다.
   * 2. 상품 등록자(판매자)에게 알림을 보냅니다.
   * ============================================================================
   */
  exports.onProductStatusPending = onDocumentUpdated(
    { document: "products/{productId}", region: "asia-southeast2" },
    async (event) => {
      const before = event.data.before.data();
      const after = event.data.after.data();

      // 'pending' 상태로 '변경'되었을 때만 실행
      if (before.status === "pending" || after.status !== "pending") {
        logger.info(`[Notify] Product ${event.params.productId} status unchanged or not pending. Skipping.`);
        return;
      }

      // 'aiVerificationStatus'가 'pending_admin'일 때 (AI가 플래그한 경우)
      if (after.aiVerificationStatus !== "pending_admin") {
        logger.info(`[Notify] Product ${event.params.productId} is pending, but not by AI. Skipping.`);
        return;
      }

      logger.info(`[Notify] AI pending status detected for product ${event.params.productId}. Sending notifications...`);

      const db = getFirestore();
      const messaging = getMessaging();
      const batch = db.batch(); // [Task 94] 알림 저장을 위한 Firestore Batch Write 생성
      const sellerId = after.userId;
      const productTitle = after.title || "Untitled Product";

      // Separate token sets for admins and seller so we can craft distinct messages
      const adminTokens = new Set();
      const sellerTokens = new Set();

      // --- 1. 관리자(들) 토큰 수집 ---
      try {
        const adminQuery = await db.collection("users")
          .where("role", "==", "admin")
          .get();

        if (!adminQuery.empty) {
          logger.info(`[Notify] Found ${adminQuery.size} admin(s).`);
          for (const doc of adminQuery.docs) {
            const tokens = doc.data()?.fcmTokens; // 'fcmTokens' 필드 가정
            if (Array.isArray(tokens)) {
              tokens.forEach((t) => adminTokens.add(t));
            }

          // [Task 94] Part A: 관리자의 'notifications' 하위 컬렉션에 알림 저장
          const adminNotifRef = db.collection("users").doc(doc.id).collection("notifications").doc();
          const adminNotifData = {
            "type": "ADMIN_PRODUCT_PENDING",
            "title": "새 AI 검토 요청",
            "body": `상품 '${productTitle}'이(가) 'pending' 상태입니다.`,
            "productId": event.params.productId,
            "createdAt": FieldValue.serverTimestamp(),
            "isRead": false,
          };
          batch.set(adminNotifRef, adminNotifData);
          }
        }
      } catch (e) {
        logger.error("[Notify] Error fetching admin tokens:", e);
      }

      // --- 2. 판매자 토큰 수집 ---
      try {
        if (sellerId) {
          const sellerDoc = await db.collection("users").doc(sellerId).get();
          if (sellerDoc.exists) {
            const tokens = sellerDoc.data()?.fcmTokens; // 'fcmTokens' 필드 가정
            if (Array.isArray(tokens)) {
              tokens.forEach((t) => sellerTokens.add(t));
            }

          // [Task 94] Part A: 판매자의 'notifications' 하위 컬렉션에 알림 저장
          const sellerNotifRef = db.collection("users").doc(sellerId).collection("notifications").doc();
          const sellerNotifData = {
            "type": "USER_PRODUCT_PENDING",
            "title": "상품 검토가 진행 중입니다",
            "body": `등록하신 상품 '${productTitle}'이(가) 관리자 검토를 위해 제출되었습니다.`,
            "productId": event.params.productId,
            "createdAt": FieldValue.serverTimestamp(),
            "isRead": false,
          };
          batch.set(sellerNotifRef, sellerNotifData);
          }
        }
      } catch (e) {
        logger.error(`[Notify] Error fetching seller ${sellerId} tokens:`, e);
      }

      const promises = [];

      // --- 3. 관리자에게 FCM 발송 (관리자 전용 메시지) ---
      const adminTokenList = Array.from(adminTokens);
      if (adminTokenList.length > 0) {
        const adminMessage = {
          notification: { title: "새 AI 검토 요청", body: `상품 '${productTitle}'이(가) 'pending' 상태입니다.` },
          data: { type: "ADMIN_PRODUCT_PENDING", productId: event.params.productId, click_action: "FLUTTER_NOTIFICATION_CLICK" },
          tokens: adminTokenList,
        };
        promises.push(messaging.sendEachForMulticast(adminMessage)
          .then((res) => logger.info(`[Notify] Sent ${res.successCount} messages to admins.`))
          .catch((e) => logger.error("[Notify] Error sending to admins:", e))
        );
      }

      // --- 4. 판매자에게 FCM 발송 (판매자 전용 메시지) ---
      const sellerTokenList = Array.from(sellerTokens);
      if (sellerTokenList.length > 0) {
        // For seller notifications we send i18n keys + args in the `data` payload.
        // The client app should localize the message using these keys and args.
        const sellerMessage = {
          // We still provide a short title to FCM notification field so some platforms
          // display something while the app is in background. The client should
          // prefer `data.title_key`/`data.body_key` when handling the message.
          notification: { title: productTitle, body: `` },
          data: {
            type: "USER_PRODUCT_PENDING",
            productId: event.params.productId,
            click_action: "FLUTTER_NOTIFICATION_CLICK",
            // i18n keys for client-side localization
            title_key: "ai_flow.notifications.seller_pending_title",
            body_key: "ai_flow.notifications.seller_pending_body",
            // Args encoded as JSON string; client can parse and replace placeholders
            body_args: JSON.stringify({ title: productTitle }),
          },
          tokens: sellerTokenList,
        };
        promises.push(
          messaging
            .sendEachForMulticast(sellerMessage)
            .then((res) => logger.info(`[Notify] Sent ${res.successCount} messages to seller.`))
            .catch((e) => logger.error("[Notify] Error sending to seller:", e))
        );
      }

      // [Task 94] Part A: FCM 전송과 동시에 Firestore에 알림 문서를 원자적으로 저장
      promises.push(batch.commit());

      await Promise.all(promises);
    }
  );

  /**
   * ============================================================================
   * [V3 NEW] 관리자가 'pending' 상품을 승인/거절할 때 알림 (Task 103/106)
   * 'products' 문서의 status가 'pending'에서 'selling' 또는 'rejected'로
   * 변경될 때 트리거됩니다.
   * 1. 판매자(seller)에게 최종 결과를 알림(FCM + Firestore)으로 보냅니다.
   * ============================================================================
   */
  exports.onProductStatusResolved = onDocumentUpdated(
    { document: "products/{productId}", region: "asia-southeast2" },
    async (event) => {
      const before = event.data.before.data();
      const after = event.data.after.data();
      const productId = event.params.productId;

      // 1. [핵심 조건] 'pending' -> 'selling' 또는 'pending' -> 'rejected' 변경 시에만 실행
      if (
        before.status !== "pending" ||
        (after.status !== "selling" && after.status !== "rejected")
      ) {
        // 'pending'에서 변경된 것이 아니므로 무시
        return;
      }

      // 2. 관리자에 의한 변경인지 확인 (Task 104에서 앱이 이 필드를 저장함)
      if (
        after.aiVerificationStatus !== "approved_by_admin" &&
        after.aiVerificationStatus !== "rejected_by_admin"
      ) {
        logger.info(`[Notify Res] Product ${productId} status changed, but not by admin. Skipping.`);
        return;
      }

      const sellerId = after.userId;
      const productTitle = after.title || "Untitled Product";
      logger.info(`[Notify Res] Admin resolution detected for ${productId}. Status: ${after.status}. Notifying seller ${sellerId}.`);

      const db = getFirestore();
      const messaging = getMessaging();
      const sellerTokens = new Set();

      // 3. 판매자 토큰 수집
      let sellerUserDoc;
      try {
        if (!sellerId) {
          logger.warn(`[Notify Res] Product ${productId} has no sellerId.`);
          return;
        }
        sellerUserDoc = await db.collection("users").doc(sellerId).get();
        if (sellerUserDoc.exists) {
          const tokens = sellerUserDoc.data()?.fcmTokens;
          if (Array.isArray(tokens)) {
            tokens.forEach((t) => sellerTokens.add(t));
          }
        }
      } catch (e) {
        logger.error(`[Notify Res] Error fetching seller ${sellerId} tokens:`, e);
        return;
      }

      // 4. 상태에 따라 알림 내용 준비
      let notifTitle = "";
      let notifBody = "";
      let notifType = "";
      let bodyArgs = {};

      if (after.status === "selling") {
        // [승인됨]
        notifType = "USER_PRODUCT_APPROVED";
        notifTitle = "상품이 승인되었습니다";
        notifBody = `축하합니다! 등록하신 상품 '${productTitle}'이(가) 관리자 검토 후 승인되었습니다.`;
        bodyArgs = { title: productTitle };
      } else {
        // [거절됨] Task 104에서 앱이 저장한 거절 사유를 가져옴
        const reason = after.rejectionReason || "관리자 정책 위반";
        notifType = "USER_PRODUCT_REJECTED";
        notifTitle = "상품 등록이 거절되었습니다";
        notifBody = `등록하신 상품 '${productTitle}'이(가) 거절되었습니다. 사유: ${reason}`;
        bodyArgs = { title: productTitle, reason: reason };
      }

      const promises = [];

      // 5. 판매자의 'notifications' 하위 컬렉션에 알림 저장
      const sellerNotifRef = db.collection("users").doc(sellerId).collection("notifications").doc();
      const sellerNotifData = {
        "type": notifType,
        "title": notifTitle, // DB에는 기본 언어(ko)로 저장
        "body": notifBody,
        "productId": productId,
        "createdAt": FieldValue.serverTimestamp(),
        "isRead": false,
      };
      promises.push(db.batch().set(sellerNotifRef, sellerNotifData).commit());

      // 6. 판매자에게 FCM 발송
      const sellerTokenList = Array.from(sellerTokens);
      if (sellerTokenList.length > 0) {
        const sellerMessage = {
          notification: { title: notifTitle, body: notifBody },
          data: {
            type: notifType,
            productId: productId,
            click_action: "FLUTTER_NOTIFICATION_CLICK",
            body_args: JSON.stringify(bodyArgs), // (앱에서 i18n 처리를 위함)
          },
          tokens: sellerTokenList,
        };
        promises.push(
          messaging.sendEachForMulticast(sellerMessage)
            .then((res) => logger.info(`[Notify Res] Sent ${res.successCount} messages to seller.`))
            .catch((e) => logger.error("[Notify Res] Error sending to seller:", e))
        );
      }

      await Promise.all(promises);
    }
  );


// 공통 onCall 옵션
const CALL_OPTS = {
  region: "asia-southeast2",
  enforceAppCheck: true,
  memory: "1GiB",
  // 장시간 이미지 다운로드 + 모델 혼잡 대비
  timeoutSeconds: 300,
  secrets: [GEMINI_KEY],
};

/**
 * [V3 REFACTOR] initialproductanalysis를 위한 새 V3 단순 프롬프트
 */
function buildV3InitialPrompt(data) {
  const { locale, categoryName, subCategoryName, userDescription, confirmedProductName } = data;
  const lc = (typeof locale === "string" && locale) || "id";
  const langName = lc === "ko" ? "Korean" : lc === "en" ? "English" : "Indonesian";

  return `
[ROLE]
You are an expert AI assistant for a second-hand marketplace.
Your task is to perform two actions based on the user's initial product registration attempt.

[USER INPUT DATA]
- Category: "${categoryName || ""}" / "${subCategoryName || ""}"
- User's Title: "${confirmedProductName || ""}"
- User's Description: "${userDescription || ""}"
- Language: You MUST respond in ${langName}.

[TASK 1: Predict Item Name]
Analyze the user input data and the provided images to predict the most accurate product name.
If the images and text are unclear, set 'prediction' to null.

[TASK 2: Suggest Additional Shots]
Analyze the user input and images. Based on the category, suggest 3-5 additional photos that would
help a buyer verify the item's condition and authenticity.
These suggestions MUST be simple, actionable text strings in ${langName}.

Examples of good suggestions:
- "배터리 성능 상태 화면을 보여주세요."
- "시리얼 번호가 보이는 라벨을 가까이서 찍어주세요."
- "스크래치나 얼룩이 있다면 그 부분을 확대해서 찍어주세요."
- "신발 밑창 마모 상태를 보여주세요."

[OUTPUT SCHEMA (JSON ONLY)]
You MUST return ONLY ONE JSON object with this exact structure.

{
  "prediction": "string (The predicted product name in ${langName}) | null",
  "suggestedShots": [
    "string (Suggestion 1 in ${langName})",
    "string (Suggestion 2 in ${langName})",
    "string (Suggestion 3 in ${langName})"
  ]
}
`;
}


// 이미지 다운로드 공통 제한
const MAX_IMAGE_BYTES = 7_500_000; // 7.5MB 안전선
const FETCH_TIMEOUT_MS = 45000; // 45s (네트워크/Storage 지연 대비)
// [v2.1] '동네 친구' 일일 신규 채팅 한도
const DAILY_CHAT_LIMIT = 5; // 하루 5명으로 제한

// Treat Gemini model resolution issues as "not found" to allow graceful fallback.
function isModelNotFoundError(err) {
  try {
    const msg =
      (err && (err.message || (err.toString && err.toString()))) || "";
    return /404|Not Found|models\/.+? is not found|is not supported for generateContent/i.test(
      msg
    );
  } catch {
    return false;
  }
}

// SDK 호환 보조: Responses API 지원 여부 체크
function hasResponsesApi(genAI) {
  return !!(
    genAI &&
    genAI.responses &&
    typeof genAI.responses.generate === "function"
  );
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
async function withRetry(
  fn,
  {
    maxRetries = GENAI_MAX_RETRIES,
    baseDelay = GENAI_BASE_DELAY_MS,
    tag = "genai",
  } = {}
) {
  let attempt = 0;
  let delay = baseDelay;
  while (true) {
    try {
      const started = Date.now();
      const result = await Promise.race([
        fn(),
        timeoutPromise(GENAI_TIMEOUT_MS, tag),
      ]);
      logger.info("⏱️ GenAI latency", {
        tag,
        attempt: attempt + 1,
        ms: Date.now() - started,
      });
      return result;
    } catch (e) {
      const retriable = isRetryable(e);
      logger.warn("↻ GenAI attempt failed", {
        tag,
        attempt: attempt + 1,
        retriable,
        err: e?.toString?.() || e,
      });
      if (attempt >= maxRetries || !retriable) throw e;
      const jitter = Math.floor(Math.random() * 200);
      await new Promise((r) => setTimeout(r, delay + jitter));
      delay *= 2;
      attempt += 1;
    }
  }
}

// SDK 버전별 호출을 감싸는 통합 함수
async function genAiCall(
  genAI,
  {
    modelPrimary = "gemini-2.5-flash",
    modelFallback = "gemini-2.5-pro",
    contents,
    safetySettings,
    responseMimeType = "application/json",
    tag,
  }
) {
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
            logger.warn(
              `⚠️ Primary model failed (${e.message}). Falling back to ${modelFallback}...`,
              { tag }
            );
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
          logger.warn(
            `⚠️ Primary model failed (${e.message}). Falling back to ${modelFallback}...`,
            { tag }
          );
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
    region: "asia-southeast2",
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
exports.initialproductanalysis = onCall(CALL_OPTS, async (request) => {
  const genAI = getGenAI();

  logger.info("✅ initialproductanalysis 함수가 호출되었습니다.", {
    auth: request.auth,
    uid: request.auth ? request.auth.uid : "No UID",
    body: request.data,
  });

  if (!request.auth) {
    logger.error(
      "❌ 치명적 오류: request.auth 객체가 없습니다. 비로그인 사용자의 호출로 간주됩니다."
    );
    throw new HttpsError(
      "unauthenticated",
      "The function must be called while authenticated."
    );
  }

  try {
  // [V3 REFACTOR] 'ruleId' 및 복잡한 룰 엔진 의존성 제거.
  // Accept: imageUrls, locale, categoryName, subCategoryName, userDescription, confirmedProductName
  const { imageUrls, locale, categoryName, subCategoryName, userDescription, confirmedProductName } = request.data || {};
  if (!Array.isArray(imageUrls) || imageUrls.length === 0) {
    logger.error("❌ 오류: 이미지 URL이 누락되었습니다.");
    throw new HttpsError("invalid-argument", "Image URLs (array) are required.");
  }

    const ac = new AbortController();
    const to = setTimeout(() => ac.abort(), FETCH_TIMEOUT_MS);
    const imageParts = await Promise.all(
      imageUrls.map(async (url) => {
        if (!/^https:\/\//i.test(url)) {
          throw new HttpsError(
            "invalid-argument",
            "Only https image URLs are allowed."
          );
        }
        let response;
        try {
          response = await fetch(url, { signal: ac.signal });
        } catch (e) {
          if (e && e.name === "AbortError")
            throw new HttpsError("deadline-exceeded", "Image fetch timed out.");
          throw e;
        }
        if (!response.ok) {
          throw new HttpsError(
            "not-found",
            `Failed to fetch image: ${response.status}`
          );
        }
        const len = Number(response.headers.get("content-length") || 0);
        if (len && len > MAX_IMAGE_BYTES) {
          throw new HttpsError(
            "resource-exhausted",
            "Image too large (>7.5MB)."
          );
        }
        const buffer = Buffer.from(await response.arrayBuffer());
        if (!len && buffer.length > MAX_IMAGE_BYTES) {
          throw new HttpsError(
            "resource-exhausted",
            "Image too large (>7.5MB)."
          );
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

  // Build V3 initial prompt and call GenAI
  const v3InitialPrompt = buildV3InitialPrompt({ locale, categoryName, subCategoryName, userDescription, confirmedProductName });
  const userContents = [{ role: "user", parts: [{ text: v3InitialPrompt }, ...imageParts] }];
  const text = await genAiCall(genAI, {
    modelPrimary: "gemini-2.5-flash",
    modelFallback: "gemini-2.5-pro",
    contents: userContents,
    safetySettings,
    responseMimeType: "application/json",
    tag: "initialproductanalysis",
  });

    // Simple V3 parsing: expect a single JSON object with { prediction, suggestedShots }
    const jsonText = extractJsonText(text);
  const parsedV3 = tryParseJson(jsonText);
  logAiDiagnostics("initialproductanalysis", text, parsedV3);
  if (!parsedV3) {
    throw new HttpsError("data-loss", "AI returned invalid JSON.");
  }

  // Minimal schema validation
  if (!Array.isArray(parsedV3.suggestedShots)) {
    logger.error("❌ CRITICAL: AI V3 initial response is missing 'suggestedShots' array.", { keys: Object.keys(parsedV3) });
    throw new HttpsError("data-loss", "AI returned invalid V3 initial structure.");
  }

  logger.info("✅ Gemini 1차 분석 성공", { prediction: parsedV3.prediction, suggestions: parsedV3.suggestedShots.length });
  return { success: true, ...parsedV3 };
  } catch (error) {
    logger.error(
      "❌ initialproductanalysis 함수 내부에서 심각한 오류 발생:",
      error
    );
    if (error instanceof HttpsError) throw error;
    // Gemini/네트워크 예외 메시지를 그대로 남기되, 상태 코드는 명확히
    const msg =
      (error && (error.message || (error.toString && error.toString()))) ||
      "Unknown";
    // SDK의 rate-limit/availability는 'unavailable'로 매핑
    if (/quota|rate|unavailable|temporarily/i.test(msg)) {
      throw new HttpsError(
        "unavailable",
        "AI service temporarily unavailable."
      );
    }
    throw new HttpsError("internal", "An internal error occurred.");
  }
});


// [V3 REFACTOR] 'normalizeFinalReportShape' (V2 정규화 헬퍼) 삭제.
// V3에서는 AI가 엄격하게 새 스키마를 반환하도록 프롬프트로 강제합니다.
function normalizeFinalReportShape(/* raw */) {
  throw new Error("normalizeFinalReportShape is removed in V3 refactor; use strict V3 schema instead.");
}

/**
 * [V3 아키텍처] (작업 37)
 * V3 "증거 패키지"와 "추출 템플릿"을 기반으로 동적 프롬프트를 생성합니다.
 * @param {object} data - 클라이언트 요청 데이터
 * @param {object} ruleData - Firestore의 V3 규칙 문서
 * @return {string} - AI에게 보낼 V3 동적 프롬프트
 */
/**
 * [V3 아키텍처] 단일 감정 엔진용 최종 보고서 프롬프트 빌더
 * - 카테고리 룰/샷 테이블에 의존하지 않고, 입력 텍스트 + 이미지만으로 감정 보고서를 생성합니다.
 * - JSON만 반환하도록 강하게 제한하여 파싱 오류를 줄입니다.
 */
function buildV3FinalPrompt(data) {
  const {
    confirmedProductName,
    userPrice,
    userDescription,
    categoryName,
    subCategoryName,
    locale,
    useFlash,
  } = data || {};

  const lc = (typeof locale === "string" && locale) || "id";
  const langName =
    lc === "ko" ? "Korean" : lc === "en" ? "English" : "Indonesian";

  const schemaText = `
[OUTPUT SCHEMA (V3.0 Simple Engine)]
You MUST respond with ONE SINGLE valid JSON object.
- Do NOT include any markdown (no backticks, no \`json).
- Do NOT include any comments (no // or /* */).
- Do NOT include trailing commas.
- JSON keys MUST be in English.
- All human-readable text MUST be in ${langName}.
- If you cannot confidently fill a field, set it to null (JSON null, not the string "null").

The JSON structure MUST be:

{
  "version": "3.0.0-simple",
  "modelUsed": "${useFlash ? "gemini-2.5-flash" : "gemini-2.5-pro"}",
  "trustVerdict": "clear | suspicious | fraud",

  "itemSummary": {
    "predictedName": "string or null",
    "categoryCheck": "string or null"
  },

  "condition": {
    "grade": "string or null",
    "gradeReason": "string or null",
    "details": [
      {
        "label": "string",
        "value": "string or null",
        "evidenceShot": "string or null"
      }
    ]
  },

  "priceAssessment": {
    "suggestedMin": "number or null",
    "suggestedMax": "number or null",
    "currency": "IDR",
    "comment": "string or null"
  },

  "notesForBuyer": "string or null",
  "verificationSummary": "string or null",

  "onSiteVerificationChecklist": {
    "title": "string",
    "checks": [
      {
        "checkPoint": "string",
        "instruction": "string"
      }
    ]
  }
}

[FIELD RULES]
- trustVerdict:
  - "clear": The listing and images look consistent and plausible.
  - "suspicious": Some details do not fully match or look unusual.
  - "fraud": The listing looks fake, impossible, or clearly manipulated.

- itemSummary.predictedName:
  - Use your best guess for the exact product/model name based on images + text.
  - If you are not at least 80% confident, set it to null.

- itemSummary.categoryCheck:
  - Briefly state in ${langName} whether the user-selected category seems correct.
  - Example: "${
    langName === "Korean"
      ? "사용자 선택 카테고리와 일치함"
      : "Category matches the item"
  }".

- condition.grade:
  - Use a simple scale like "A+", "A", "B", "C" based on overall condition.
  - If images are too blurry to judge, set grade to null and explain in gradeReason.

- condition.details:
  - Use around 2–5 key aspects such as "화면 상태", "배터리 성능", "외관 스크래치", "액세서리 포함 여부".
  - Each detail.value MUST be based on visible evidence or user description.
  - If you are not at least 80% confident for a detail, set its value to null and explain in notesForBuyer.

- priceAssessment:
  - suggestedMin / suggestedMax are numbers in IDR.
  - Use your internal knowledge to estimate a realistic price range.
  - If you cannot estimate, set both to null and explain briefly in comment.

- notesForBuyer:
  - Short 1–3 sentences in ${langName} with practical warnings or advice for the buyer.

- verificationSummary:
  - 1–3 sentences in ${langName} summarizing your verification decision.

- onSiteVerificationChecklist:
  - title: a short title in ${langName}, e.g., "현장 구매자 안심 체크리스트".
  - checks: normally 2–3 items (minimum 1).
  - Each checkPoint is a specific item to verify on-site.
  - Each instruction explains briefly HOW to check it in ${langName}.

[SAFETY RULES]
- Never invent data that is not supported by the images or user text.
- If an image is blurry, unreadable, or does not contain the claimed information:
  - Do NOT guess. Use null and explain in gradeReason or notesForBuyer.
- If you are not at least 80% confident about:
  - itemSummary.predictedName
  - condition.details[].value
  - priceAssessment.suggestedMin / suggestedMax
  then set those specific fields to null.
  // Attribute / date specific safety (all categories)
- Listings can cover many different product types (electronics, fashion, furniture, books, etc.).
- You do NOT have a complete, real-time catalog of all possible product models, version numbers, or official release dates.
- You MUST NOT claim that a model name, version string, size, or date is "impossible", "non-existent", or "fake"
  only because it looks unfamiliar to you, uses an unusual naming style, or appears to be in the future
  relative to your current date.
- If any technical identifier or date (for example a firmware version, serial/model code, or manufacture/use date)
  looks unusual or unexpected, treat it as "unverified" data.
  In that case you may at most use trustVerdict = "suspicious" with clear advice for the buyer to double-check
  with the seller or official sources, but you MUST NOT label it as "fraud" based solely on such unusual values.
- Only use trustVerdict = "fraud" when there is strong internal contradiction between the listing text and
  the images themselves (for example, two clearly different products or identifiers shown for the same claimed item).
`;

  const finalPrompt = `
[ROLE]
You are an expert product inspector for a high-trust second-hand marketplace.
Your task is to analyze all provided images and text data and generate a comprehensive, structured JSON report.
You MUST adhere strictly to the [OUTPUT SCHEMA].

${schemaText}

[CONTEXT]
- The current date is: ${new Date().toISOString()}
 - The current date is provided only for basic consistency checks inside a single listing.
 - You may use it to notice obvious contradictions within the same item (for example,
   a "first use" date that is clearly earlier than a printed manufacture date on the same label,
   or two different years printed for the same production field).
 - You MUST NOT treat a date as invalid or evidence of fraud only because it is close
   to or slightly after the current date, or because you are unsure whether a future
   model/version/date is officially released.
 - In such cases, treat the information as "unverified" and advise
   the buyer to confirm it directly on-site (for example by checking labels, menus,
   or official documentation with the seller).

[USER INPUT]
- Product Name Claim: "${confirmedProductName || ""}"
- Category: "${categoryName || ""}" / "${subCategoryName || ""}"
- User Price: "${userPrice || ""}"
- User Description: "${userDescription || ""}"

[IMAGES]
The user has provided multiple images. Analyze ALL of them to find evidence for:
- Item name, model, and specs (e.g., storage, battery health, serial/IMEI).
- Physical condition (scratches, dents, screen-on state, wear and tear).
- Included items (box, charger, cable, accessories).
- Any signals of tampering or fake images.

[TASKS]
1. Analyze & Extract:
   - Fill every field in the [OUTPUT SCHEMA] based on [USER INPUT] and [IMAGES].
   - If a field cannot be reliably filled, use null and explain briefly in notesForBuyer.

2. Assess Price:
   - Compare the "User Price" with a realistic market range in IDR using your internal knowledge.
   - Set priceAssessment.suggestedMin / suggestedMax and comment accordingly.

3. Generate On-site Checklist (CRITICAL):
   - Create "onSiteVerificationChecklist" with normally 2–3 essential checks a buyer should perform on-site (minimum 1).
   - Example checks: "Check IMEI matches the device", "Test camera and microphone", "Check battery health menu".

4. Trust Verdict (CRITICAL):
   - Analyze all data (text + images) for fraud or inconsistency signals.
   - If the user's claims (model, condition) are well-supported and plausible, set trustVerdict = "clear".
   - If some details are inconsistent, impossible for the claimed model/year, or look manipulated, use "suspicious" or "fraud" and explain in verificationSummary and notesForBuyer.

[OUTPUT]
Return ONLY the final JSON object.
Do NOT add any explanation, text, or markdown outside of the JSON.
`;

  return finalPrompt;
}


/**
 * [V2 최종 수정] 모든 이미지와 정보를 종합하여 최종 판매 보고서를 생성합니다.
 */
exports.generatefinalreport = onCall(CALL_OPTS, async (request) => {
  const genAI = getGenAI();
  const { imageUrls, locale } = request.data || {};

  if (!imageUrls) {
    throw new HttpsError("invalid-argument", "Required data is missing: imageUrls.");
  }

  try {
    // Build a V3 final report prompt using the simplified generator.
    const v3Prompt = buildV3FinalPrompt(request.data);

    // [V3] 1차(initial) + 2차(guided) 이미지 URL을 모두 추출합니다.
    const allImageUrls = [
      ...(imageUrls.initial || []),
      ...Object.values(imageUrls.guided || {}),
    ];

    const ac = new AbortController();
    const to = setTimeout(() => ac.abort(), FETCH_TIMEOUT_MS);

    // ... (이미지 처리 로직은 동일)
    const imageParts = await Promise.all(
      allImageUrls.map(async (url) => {
        if (!/^https:\/\//i.test(url)) {
          throw new HttpsError(
            "invalid-argument",
            "Only https image URLs are allowed."
          );
        }
        let response;
        try {
          response = await fetch(url, { signal: ac.signal });
        } catch (e) {
          if (e && e.name === "AbortError")
            throw new HttpsError("deadline-exceeded", "Image fetch timed out.");
          throw e;
        }
        if (!response.ok) {
          throw new HttpsError(
            "not-found",
            `Failed to fetch image: ${response.status}`
          );
        }
        const len = Number(response.headers.get("content-length") || 0);
        if (len && len > MAX_IMAGE_BYTES) {
          throw new HttpsError(
            "resource-exhausted",
            "Image too large (>7.5MB)."
          );
        }
        const buffer = Buffer.from(await response.arrayBuffer());
        if (!len && buffer.length > MAX_IMAGE_BYTES) {
          throw new HttpsError(
            "resource-exhausted",
            "Image too large (>7.5MB)."
          );
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

    const jsonStr = (
      await genAiCall(genAI, {
        modelPrimary: "gemini-2.5-flash",
        modelFallback: "gemini-2.5-pro",
        contents: [
          { role: "user", parts: [{ text: v3Prompt }, ...imageParts] },
        ],
        safetySettings,
        responseMimeType: "application/json",
        tag: "generatefinalreport",
      })
    ).trim();

    const jsonBlock = extractJsonText(jsonStr);
    let report = tryParseJson(jsonBlock);
    logAiDiagnostics("generatefinalreport", jsonStr, report);
    if (!report) {
      // [V3 HOTFIX] JSON 파싱 자체가 실패한 경우, 안전한 Fallback 객체 생성
      report = {};
    }

    // [V3 REFACTOR] AI가 새 V3 스키마를 따랐는지 최소한으로 검증합니다.
    if (!report.itemSummary || !report.condition || !report.onSiteVerificationChecklist) {
      logger.error("❌ CRITICAL: AI V3 response is missing critical fields (itemSummary, condition, or onSiteVerificationChecklist). Generating fallback.", {
        keys: Object.keys(report),
      });
      // [V3 HOTFIX] 'data-loss' 예외를 던지는 대신, 앱 크래시를 막기 위해
      // '안전한 폴백(Fallback) 리포트'를 반환합니다.
      report = {
        version: "3.0.0-fallback",
        modelUsed: "gemini-2.5-pro",
        itemSummary: report.itemSummary || { predictedName: null, categoryCheck: "AI 분석 실패" },
        condition: report.condition || { grade: "N/A", gradeReason: "AI가 상태 분석에 실패했습니다.", details: [] },
        priceAssessment: report.priceAssessment || { suggestedMin: null, suggestedMax: null, currency: "IDR", comment: "AI가 가격 분석에 실패했습니다." },
        notesForBuyer: report.notesForBuyer || "AI가 세부 보고서를 생성하는 데 실패했습니다. 판매자에게 직접 문의하세요.",
        verificationSummary: report.verificationSummary || "AI 분석에 실패했습니다. (Invalid V3 Structure)",
        onSiteVerificationChecklist: report.onSiteVerificationChecklist || { title: "AI 분석 실패", checks: [] },
      };
    }

    // NOTE: Previously we injected `source_image_url` server-side using
    // `found_evidence` and `key_specs`. Under the V3 approach we prefer the
    // model to reference evidence identifiers directly and the client to map
    // those identifiers to URLs. If server-side injection is required later,
    // reintroduce a controlled mapping here.

    // [추적 코드 2] 성공 직전 최종 로그
    logger.info(
      "✅ Final report generated successfully. Preparing to return.",
      { reportObjectKeys: Object.keys(report) }
    );

    // [최종 추적 코드] 객체를 문자열로 변환(직렬화)하는 과정에서 오류가 발생하는지 명시적으로 확인합니다.
    try {
      const reportString = JSON.stringify(report);
      logger.info(
        `✅ Report object successfully serialized. Length: ${reportString.length}. Returning to client.`
      );
    } catch (serializationError) {
      // 만약 여기서 에러가 발생하면, Gemini가 보낸 report 객체에 문제가 있는 것입니다.
      logger.error("❌ CRITICAL: Failed to serialize the report object.", {
        error: serializationError.toString(),
        reportObjectKeys: Object.keys(report),
      });
      // 직렬화 실패는 복구 불가능하므로, 명확한 에러를 던집니다.
      throw new HttpsError(
        "internal",
        "Failed to process the AI report due to a serialization error."
      );
    }

    // [최종 복원] 진단용 임시 코드를 삭제하고, 실제 AI 리포트를 반환하는 원래 코드를 활성화합니다.
    return { success: true, report };
  } catch (error) {
    logger.error(
      "Final report generation failed:",
      error?.toString?.() || error
    );
    if (error instanceof HttpsError) throw error;
    const msg =
      (error && (error.message || (error.toString && error.toString()))) ||
      "Unknown";
    if (/quota|rate|unavailable|temporarily/i.test(msg)) {
      throw new HttpsError(
        "unavailable",
        "AI final report temporarily unavailable."
      );
    }
    throw new HttpsError("internal", "AI final report generation failed.");
  }
});

// [신규] URL로부터 이미지를 다운로드하여 Gemini API가 요구하는 형식으로 변환하는 헬퍼 함수
async function urlToGenerativePart(url) {
  if (!/^https:\/\//i.test(url)) {
    throw new HttpsError(
      "invalid-argument",
      `Invalid URL format: ${url}. Only https is allowed.`
    );
  }
  const ac = new AbortController();
  const to = setTimeout(() => ac.abort(), FETCH_TIMEOUT_MS);
  let response;
  try {
    response = await fetch(url, { signal: ac.signal });
  } catch (e) {
    if (e && e.name === "AbortError")
      throw new HttpsError(
        "deadline-exceeded",
        `Image fetch timed out for url: ${url}`
      );
    throw e;
  } finally {
    clearTimeout(to);
  }
  if (!response.ok)
    throw new HttpsError(
      "not-found",
      `Failed to fetch image from ${url}: ${response.status}`
    );
  const contentType = response.headers.get("content-type") || "image/jpeg";
  const buffer = Buffer.from(await response.arrayBuffer());
  if (buffer.length > MAX_IMAGE_BYTES)
    throw new HttpsError(
      "resource-exhausted",
      `Image from ${url} is too large (>7.5MB).`
    );
  return {
    inlineData: {
      mimeType: contentType,
      data: buffer.toString("base64"),
    },
  };
}

/**
 * ============================================================================
 * [V2] 기존 상품에 AI 검수 리포트를 추가하여 '강화'합니다.
 * ============================================================================
 */
exports.enhanceProductWithAi = onCall(CALL_OPTS, async (request) => {
  logger.info("✅ [V2] enhanceProductWithAi 함수가 호출되었습니다.", {
    uid: request.auth ? request.auth.uid : "No UID",
    body: request.data,
  });

  if (!request.auth) {
    throw new HttpsError(
      "unauthenticated",
      "The function must be called while authenticated."
    );
  }

  try {
    const { productId, evidenceImageUrls } = request.data || {};
    if (
      !productId ||
      !Array.isArray(evidenceImageUrls) ||
      evidenceImageUrls.length === 0
    ) {
      throw new HttpsError(
        "invalid-argument",
        "productId and evidenceImageUrls (array) are required."
      );
    }

    const db = getFirestore();
    const genAI = getGenAI();

    // 1. productId로 Firestore에서 상품 데이터 가져오기
    const productRef = db.collection("products").doc(productId);
    const productDoc = await productRef.get();
    if (!productDoc.exists) {
      throw new HttpsError(
        "not-found",
        `Product with ID ${productId} not found.`
      );
    }
    const productData = productDoc.data();
    const categoryId = productData.categoryId;
    if (!categoryId) {
      throw new HttpsError(
        "failed-precondition",
        `Product ${productId} does not have a categoryId.`
      );
    }

    // 2. 상품 데이터 기반으로 V3 프롬프트 생성 (ai_verification_rules 의존성 제거)
    const confirmedProductName = productData.title || "";
    const categoryName = productData.categoryName || "";
    const subCategoryName = productData.subCategoryName || "";

    // Build a V3 final prompt for the enhancement flow. We prefer using the
    // V3 structured prompt builder instead of fetching ai_verification_rules.
    const v3Prompt = buildV3FinalPrompt({
      confirmedProductName,
      userPrice: productData.price,
      userDescription: productData.description,
      categoryName,
      subCategoryName,
      locale: request.data?.locale,
      useFlash: false,
    });

    // 3. 증거 이미지 준비 및 Gemini API 호출
    const imageParts = await Promise.all(
      evidenceImageUrls.map((url) => urlToGenerativePart(url))
    );

    const contents = [{ role: "user", parts: [{ text: v3Prompt }, ...imageParts] }];
    const rawResponseText = await genAiCall(genAI, {
      contents,
      safetySettings,
      responseMimeType: "application/json",
      tag: "enhanceProductWithAi",
    });

    // 4. productId에 해당하는 상품 문서에 aiReport 업데이트
    const jsonText = extractJsonText(rawResponseText);
    const aiReport = tryParseJson(jsonText);
    logAiDiagnostics("enhanceProductWithAi", rawResponseText, aiReport);
    if (!aiReport) {
      throw new HttpsError(
        "data-loss",
        "AI returned invalid JSON for the enhancement report."
      );
    }

    // ---------------------------------------------------------
    // [V3.1 UPDATE] ai_cases 문서 생성 및 Dual Write
    // ---------------------------------------------------------
    const caseRef = db.collection("ai_cases").doc(); // 새 문서 ID 자동 생성
    const caseId = caseRef.id;
    const now = FieldValue.serverTimestamp();

    const aiCaseData = {
      caseId: caseId,
      productId: productId,
      sellerId: productData.sellerId || request.auth.uid,
      buyerId: null, // 등록/검수 단계이므로 null
      stage: "enhancement",
      status: "completed",
      aiResult: aiReport, // 분석 결과 원본 보존
      evidenceImageUrls: evidenceImageUrls || [], // 사용된 증거 이미지 보존
      verdict: aiReport.trustVerdict || "pending",
      createdAt: now,
      updatedAt: now,
    };

    const batch = db.batch();
    batch.set(caseRef, aiCaseData);

    // products 문서 업데이트 (요약 정보 + 레거시 호환)
    batch.update(productRef, {
      lastAiCaseId: caseId,
      lastAiVerdict: aiCaseData.verdict,
      aiVerificationStatus: aiCaseData.verdict === 'safe' ? 'verified' : 'suspicious',
      aiSummaryShort: aiReport.itemSummary?.title || "AI 검수 완료",
      aiReport: aiReport, // [Legacy 호환용] 당분간 유지
      updatedAt: now,
    });

    await batch.commit();

    logger.info(`✅ [AI Case Created] ${caseId} for Product ${productId}`);

    return { success: true, report: aiReport, caseId: caseId };
  } catch (error) {
    logger.error(
      "❌ [V2] enhanceProductWithAi 함수 내부에서 오류 발생:",
      error
    );
    if (error instanceof HttpsError) throw error;
    throw new HttpsError(
      "internal",
      "An internal error occurred during AI enhancement."
    );
  }
});

// [업데이트] Gemini 안전 설정 (최신 카테고리 명칭 사용)
// 허용 카테고리: DANGEROUS_CONTENT, HARASSMENT, HATE_SPEECH, SEXUALLY_EXPLICIT, CIVIC_INTEGRITY
const safetySettings = [
  {
    category: HarmCategory.HARM_CATEGORY_DANGEROUS_CONTENT,
    threshold: HarmBlockThreshold.BLOCK_NONE,
  },
  {
    category: HarmCategory.HARM_CATEGORY_HARASSMENT,
    threshold: HarmBlockThreshold.BLOCK_MEDIUM_AND_ABOVE,
  },
  {
    category: HarmCategory.HARM_CATEGORY_HATE_SPEECH,
    threshold: HarmBlockThreshold.BLOCK_MEDIUM_AND_ABOVE,
  },
  {
    category: HarmCategory.HARM_CATEGORY_SEXUALLY_EXPLICIT,
    threshold: HarmBlockThreshold.BLOCK_MEDIUM_AND_ABOVE,
  },
  {
    category: HarmCategory.HARM_CATEGORY_CIVIC_INTEGRITY,
    threshold: HarmBlockThreshold.BLOCK_MEDIUM_AND_ABOVE,
  },
];


// ----------------------------------------------------------------------
// [푸시 스키마] 하이브리드 기획안 3. 푸시 구독 스키마
// ----------------------------------------------------------------------

/**
 * PushPrefs 객체에서 구독할 FCM 토픽 이름 목록을 생성합니다.
 * @param {object} prefs - user.pushPrefs 객체
 * @return {Set<string>} - 구독할 토픽 이름의 Set
 */
function buildTopicsFromPrefs(prefs) {
  const { scope, tags, regionKeys } = prefs || {};

  // scope/regionKeys 가 유효하지 않으면 토픽 생성 불가
  if (!scope || !regionKeys || !regionKeys[scope]) {
    return new Set();
  }

  // 태그가 없으면 태그 기반 구독 없음
  if (!tags || !Array.isArray(tags) || tags.length === 0) {
    return new Set();
  }

  // 1) 기준 지역 키 (예: 'DKI|Jakarta Barat|Palmerah|Slipi')
  const regionKey = String(regionKeys[scope] || "");
  // 2) 토픽 베이스 문자열 생성 (공백/특수문자 정리)
  const baseTopic = `news.${scope}.${regionKey
    .replace(/[| ]/g, "-")
    .replace(/[^a-zA-Z0-9-]/g, "")}`;

  // 3) 태그별 최종 토픽 만들기
  const topics = new Set();
  for (const tag of tags) {
    topics.add(`${baseTopic}.${String(tag)}`);
  }
  return topics;
}

/**
 * users/{uid} 문서의 pushPrefs 변경 시 FCM 토픽 구독을 동기화합니다.
 */
exports.onUserPushPrefsWrite = onDocumentUpdated(
  { document: "users/{uid}", region: "asia-southeast2" },
  async (event) => {
    const change = event.data;
    if (!change) {
      logger.log("No data change found.");
      return;
    }

    const beforeData = change.before.data() || {};
    const afterData = change.after.data() || {};

    // pushPrefs 미존재 시 종료
    if (!afterData.pushPrefs) {
      logger.log("No pushPrefs found in afterData.");
      return;
    }
    // 변경 없음 시 종료
    if (
      JSON.stringify(beforeData.pushPrefs || {}) ===
      JSON.stringify(afterData.pushPrefs || {})
    ) {
      logger.log("pushPrefs did not change.");
      return;
    }

    logger.log(`Processing pushPrefs for user ${event.params.uid}`);

    const beforePrefs = beforeData.pushPrefs || {};
    const afterPrefs = afterData.pushPrefs || {};

    const oldTopics = new Set(beforePrefs.subscribedTopics || []);
    const newTopics = buildTopicsFromPrefs(afterPrefs);

    const oldTokens = new Set(beforePrefs.deviceTokens || []);
    const newTokens = new Set(afterPrefs.deviceTokens || []);

    const messaging = getMessaging();
    const promises = [];

    // 1) 제거된 토큰을 이전 토픽들에서 구독 해제
    const tokensRemoved = Array.from(oldTokens).filter(
      (t) => !newTokens.has(t)
    );
    if (tokensRemoved.length > 0 && oldTopics.size > 0) {
      for (const topic of oldTopics) {
        promises.push(messaging.unsubscribeFromTopic(tokensRemoved, topic));
      }
    }

    // 2) 현재 토큰들을 제거된 토픽에서 구독 해제
    const topicsRemoved = Array.from(oldTopics).filter(
      (t) => !newTopics.has(t)
    );
    const currentTokens = Array.from(newTokens);
    if (currentTokens.length > 0 && topicsRemoved.length > 0) {
      for (const topic of topicsRemoved) {
        promises.push(messaging.unsubscribeFromTopic(currentTokens, topic));
      }
    }

    // 3) 추가된 토큰들을 새 토픽에 구독
    const tokensAdded = Array.from(newTokens).filter(
      (t) => !oldTokens.has(t)
    );
    if (tokensAdded.length > 0 && newTopics.size > 0) {
      for (const topic of newTopics) {
        promises.push(messaging.subscribeToTopic(tokensAdded, topic));
      }
    }

    // 4) 현재 토큰들을 추가된 토픽에 구독
    const topicsAdded = Array.from(newTopics).filter(
      (t) => !oldTopics.has(t)
    );
    if (currentTokens.length > 0 && topicsAdded.length > 0) {
      for (const topic of topicsAdded) {
        promises.push(messaging.subscribeToTopic(currentTokens, topic));
      }
    }

    try {
      await Promise.all(promises);
      logger.log("FCM topic subscriptions updated successfully.");
    } catch (error) {
      logger.error("Error updating FCM subscriptions:", error);
    }

    // 5) Firestore에 최종 구독 토픽 목록 반영
    const newTopicsArray = Array.from(newTopics);
    if (
      JSON.stringify(beforePrefs.subscribedTopics || []) !==
      JSON.stringify(newTopicsArray)
    ) {
      try {
        await change.after.ref.update({
          "pushPrefs.subscribedTopics": newTopicsArray,
        });
        logger.log("Updated subscribedTopics in Firestore.");
      } catch (error) {
        logger.error("Error updating subscribedTopics in Firestore:", error);
      }
    }
  }
);

// ----------------------------------------------------------------------
// [게시판] 하이브리드 기획안 4. 동네 게시판 자동 생성
// ----------------------------------------------------------------------

/**
 * [헬퍼 함수]
 * Post의 adminParts에서 Kelurahan 키를 생성합니다.
 * 예: { prov: "DKI", kab: "Jakarta Barat", ... } -> "DKI|Jakarta Barat|Palmerah|Slipi"
 * @param {object} adminParts - 게시글의 adminParts
 * @return {string|null} - "prov|kab|kec|kel" 형식의 키
 */
function getKelKey(adminParts) {
  if (
    !adminParts ||
    !adminParts.prov ||
    !adminParts.kab ||
    !adminParts.kec ||
    !adminParts.kel
  ) {
    return null;
  }
  return `${adminParts.prov}|${adminParts.kab}|${adminParts.kec}|${adminParts.kel}`;
}

/**
 * [게시판] onPostCreate (Local News 전용)
 * 'posts' 컬렉션에 'local_news' 카테고리(또는 태그)의 문서가 생성될 때마다
 * 해당 Kelurahan의 'boards/{kel_key}' 문서를 찾아 통계를 업데이트합니다.
 *
 * 기획안: "onPostCreate ... /boards/{kel_key} upsert. metrics.last30dPosts++"
 */
exports.onLocalNewsPostCreate = onDocumentCreated(
  { document: "posts/{postId}", region: "asia-southeast2" },
  async (event) => {
    const db = getFirestore();

    const postData = event.data.data();

    // 1. local_news 게시글인지 확인 (tags 필드가 있는지로 간단히 확인)
    if (!postData?.tags || !Array.isArray(postData.tags) || postData.tags.length === 0) {
      logger.log("Post has no tags, skipping board metric update.");
      return;
    }

    // 2. Kelurahan 키 추출
    const kelKey = getKelKey(postData.adminParts);
    if (!kelKey) {
      logger.warn(`Post ${event.params.postId} has invalid adminParts.`);
      return;
    }

    const boardRef = db.collection("boards").doc(kelKey);

    // ✅ 트랜잭션으로 안전하게 카운트 증가 및 임계값 판단
    try {
      await db.runTransaction(async (transaction) => {
        const boardDoc = await transaction.get(boardRef);

        // ✅ 런칭 초기 임계값 10으로 설정
        const ACTIVATION_THRESHOLD = 10;

        let newPostCount = 1;
        let currentFeatures = { hasGroupChat: false };

        if (boardDoc.exists) {
          const data = boardDoc.data() || {};
          const metrics = data.metrics || {};
          const features = data.features || {};
          // NOTE: 테스트 단계에서는 30일 기준 없이 단순 누적 카운트만 사용합니다. (추후 롤링 카운트가 필요하면 스케줄러로 전환)
          newPostCount = (metrics.last30dPosts || 0) + 1;
          currentFeatures = features;
        }

        const shouldActivate = newPostCount >= ACTIVATION_THRESHOLD;

        transaction.set(
          boardRef,
          {
            key: kelKey,
            metrics: {
              last30dPosts: newPostCount,
            },
            features: {
              ...currentFeatures,
              hasGroupChat: shouldActivate, // ✅ 10건 도달 시 true
            },
            label: {
              en: `${postData.adminParts.kel}, ${postData.adminParts.kec}`,
              id: `${postData.adminParts.kel}, ${postData.adminParts.kec}`,
              ko: `${postData.adminParts.kel}, ${postData.adminParts.kec}`,
            },
            createdAt: FieldValue.serverTimestamp(), // (Upsert) 생성 시에만 적용
            updatedAt: FieldValue.serverTimestamp(), // 항상 업데이트
          },
          { merge: true }
        );
      });

      logger.log(`Updated board metrics for kel_key: ${kelKey}.`);
    } catch (error) {
      logger.error(`Failed to update board metrics for ${kelKey}:`, error);
    }
  });

// ============================================================================
// [v2.1] 신규: '동네 친구' 신규 채팅 한도 확인 및 시작
// ============================================================================

/**
 * UTC 기준 오늘 날짜를 YYYY-MM-DD 형식으로 반환합니다.
 * @return {string} 오늘 날짜 (예: "2025-11-06")
 */
function getTodayUTC() {
  const now = new Date();
  return now.toISOString().split("T")[0];
}

/**
 * '동네 친구'를 통해 새 채팅을 시작할 수 있는지 확인하고, 가능한 경우 카운트를 증가시킵니다.
 *
 * @param {onCall.Request} request
 * @param {string} request.data.otherUserId - 대화를 시도할 상대방 UID
 * @return {Promise<{allow: boolean, isExisting: boolean, limit?: number, count?: number}>}
 */
exports.startFriendChat = onCall(CALL_OPTS, async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "인증이 필요합니다.");
  }

  const uid = request.auth.uid;
  const {otherUserId} = request.data;

  if (!otherUserId) {
    throw new HttpsError("invalid-argument", "상대방 ID(otherUserId)가 필요합니다.");
  }

  if (uid === otherUserId) {
    throw new HttpsError("invalid-argument", "자신과 대화할 수 없습니다.");
  }

  const db = getFirestore(); // getFirestore()는 이미 상단에서 가져옴
  const userRef = db.collection("users").doc(uid);

  // 1. 기존 채팅방이 있는지 확인합니다. (기존 채팅방은 한도와 무관)
  const ids = [uid, otherUserId];
  ids.sort();
  const chatId = ids.join("_");
  const chatRoomRef = db.collection("chats").doc(chatId);

  const chatRoomDoc = await chatRoomRef.get();
  if (chatRoomDoc.exists) {
    return {allow: true, isExisting: true}; // 한도 확인 불필요
  }

  // 2. 신규 채팅인 경우, 한도를 확인합니다.
  const userDoc = await userRef.get();
  if (!userDoc.exists) {
    throw new HttpsError("not-found", "사용자 문서를 찾을 수 없습니다.");
  }

  const chatLimits = userDoc.data()?.chatLimits || {};
  const currentCount = chatLimits.findFriendCount || 0;
  const lastReset = chatLimits.findFriendLastReset || ""; // YYYY-MM-DD
  const today = getTodayUTC();

  let newCount = currentCount;

  // 3. 날짜가 다르면 카운트 리셋
  if (lastReset !== today) {
    newCount = 0;
  }

  // 4. 한도 확인
  if (newCount < DAILY_CHAT_LIMIT) {
    // 5. 한도 미만: 허용, 카운트 1 증가
    try {
      await userRef.update({
        "chatLimits.findFriendCount": FieldValue.increment(1),
        "chatLimits.findFriendLastReset": today,
      });
      return {allow: true, isExisting: false, count: newCount + 1};
    } catch (error) {
      logger.error("startFriendChat 카운트 업데이트 실패:", error);
      throw new HttpsError("internal", "카운트 업데이트 중 오류가 발생했습니다.");
    }
  } else {
    // 6. 한도 도달: 거부
    return {
      allow: false,
      isExisting: false,
      limit: DAILY_CHAT_LIMIT,
      count: newCount,
    };
  }
});

/**
 * ============================================================================
 * [AI 인수 2단계] 현장 동일성 검증
 * 구매자가 현장에서 촬영한 사진과 원본 AI 보고서/사진을 비교합니다.
 * ============================================================================
 */
exports.verifyProductOnSite = onCall(CALL_OPTS, async (request) => {
  logger.info("✅ [AI 인수 2단계] verifyProductOnSite 함수가 호출되었습니다.", {
    uid: request.auth ? request.auth.uid : "No UID",
    body: request.data,
  });

  if (!request.auth) {
    throw new HttpsError("unauthenticated", "인증이 필요합니다.");
  }

  const { productId, newImageUrls, locale } = request.data || {};
  if (
    !productId ||
    !Array.isArray(newImageUrls) ||
    newImageUrls.length === 0
  ) {
    throw new HttpsError(
      "invalid-argument",
      "productId 및 newImageUrls (배열)가 필요합니다."
    );
  }

  const db = getFirestore();
  const genAI = getGenAI();

  try {
    // 1. 원본 상품 데이터 및 AI 보고서 가져오기
    const productRef = db.collection("products").doc(productId);
    const productDoc = await productRef.get();
    if (!productDoc.exists) {
      throw new HttpsError("not-found", `상품(ID: ${productId})을 찾을 수 없습니다.`);
    }

      const productData = productDoc.data();
      const originalReport = productData.aiReport;
      const originalImageUrls = productData.imageUrls;

      // [Debug] 기존 이미지 확인
      const originalImages = Array.isArray(originalImageUrls) ? originalImageUrls : [];
      if (originalImages.length === 0) {
        logger.warn(`⚠️ Product ${productId} has no original images.`);
      }

      // [Task 115 HOTFIX] Copilot이 발견한 NPE(Null) 오류 수정
      // 'originalReport'가 null인지 먼저 확인해야 합니다.
      if (!originalReport) {
        throw new HttpsError(
          "failed-precondition",
          "AI 검증이 완료된 상품이 아닙니다." // "AI verified product is not."
        );
      }

      // [V3 TAKEOVER] Extract the V3 checklist to use in the prompt
      const onSiteChecklist = originalReport.onSiteVerificationChecklist;
      if (!onSiteChecklist || !onSiteChecklist.checks) {
        throw new HttpsError("failed-precondition", "AI Report is missing 'onSiteVerificationChecklist'.");
      }

    // 2. 비교 프롬프트 생성
    const lc = (typeof locale === "string" && locale) || "id";
    const langName =
      lc === "ko" ? "Korean" : lc === "en" ? "English" : "Indonesian";

    const verificationPrompt = `
      [ROLE]
      You are an expert visual inspector for a high-trust second-hand marketplace.
      Your task is to compare two sets of images: [PACKET A] (the seller's original photos) and [PACKET B] (the buyer's new on-site photos).
      
      **[CRITICAL INSTRUCTION]**
      Packet A contains ALL original photos from the listing.
      Packet B contains new photos specifically taken to verify the [CHECKLIST] below.
      You must allow for different angles/lighting, but the ITEM itself must be the same.

      **[CONTEXT]**
      1. **Full AI Report (Reference):** ${JSON.stringify(originalReport)}
         - Use this to understand the item's claimed condition, grade, and known defects.
      2. **On-Site Checklist (Target):** ${JSON.stringify(onSiteChecklist)}
         - The buyer specifically tried to capture these points in Packet B.

      **IMPORTANT SCOPE RULES**
      - Listings can be any type of second-hand item (electronics, clothing, furniture, etc.).
      - Your ONLY responsibility in this task is to decide whether [PACKET B] appears to show the SAME physical item
        as [PACKET A], and whether there are new visible defects or damages.
      - **Handling Screen/Settings Photos:**
        * Packet B will likely contain screenshots or photos of digital screens (Settings, IMEI, Battery Health) as requested by the checklist.
        * These screens will NOT look like the physical body of the device shown in Packet A. This is NORMAL.
        * If Packet B shows the correct Model/IMEI/OS version claimed in the product report, treat this as a **STRONG MATCH**. Do NOT reject because it doesn't visually match the body/corners of Packet A.
      - **Condition Verification:**
         * Check if the condition shown in Packet B matches the 'grade' and 'defects' described in the [Full AI Report].
         * If Packet B shows the *same* scratches/dents mentioned in the report, that is a MATCH (confirming identity).
         * Only flag as 'discrepancy' if Packet B shows **NEW, unreported damage** or if the item is in significantly *worse* condition than claimed.
      - You MUST NOT decide whether version numbers, serial/model codes, sizes, labels, or dates are "real", "official",
        or "released" in the real world. You do not have a complete or up-to-date catalog of all possible products.
      - If [PACKET A] and [PACKET B] consistently show the same unusual identifier or date
        (for example a strange firmware string, batch code, or manufacture date),
        you should treat this as a visual MATCH between the two packets. In that case:
          * set "match" to true, and
          * optionally add a warning about the unusual value in "discrepancies" (for the buyer to double-check),
            but DO NOT claim that it is definitely fake or impossible.
      - Use "match": false only when [PACKET B] clearly shows a different item (for example,
        a different colour or pattern, a different product type, clearly different identifiers such as
        serial/model codes or logos, or new large damage that was not present in [PACKET A]).
      - Use "match": null only when the [PACKET B] photos are too blurry, too dark, or incomplete so that you
        cannot reasonably compare them to [PACKET A] OR verify the checklist.
      - Do NOT give instructions like "cancel the transaction" or "request a refund". Just describe the factual
        differences; the app will decide how to handle the transaction.

      **Task:**
      1. **Compare [PACKET A] and [PACKET B]** to determine if they show the exact same item according to the scope rules above.
      2. **Check for New Defects:** Look for any new scratches, cracks, dents, or screen issues in [PACKET B] that are NOT visible in [PACKET A].
      3. Provide a clear 'match' (true/false/null) and a 'reason' for your decision. The 'reason' must be written in ${langName}.
      4. If the new photos in [PACKET B] are too blurry, dark, or do not show the item clearly enough to make a comparison,
         or if they do not cover enough of the checklist items, set 'match' to null.

      **Output Format (JSON ONLY):**
      {
       "match": true | false | null,
       "reason": "string (Your explanation in ${langName}. Example: 'Item matches original photos.' or 'New photos show a large crack on the screen that was not present in original photos.')",
       "discrepancies": ["string (List any specific differences found in ${langName})"]
      }
    `;

    // [Debug] 입력 데이터 로깅
    logger.info(`🔍 AI Compare Start: Original ${originalImages.length} vs New ${newImageUrls.length}`);

    // 3. 현장 사진(newImageUrls) 및 원본 사진(originalImageUrls)을 GenerativePart로 변환
    // [V3.1 Full Inspection] 제한 해제: 현장 사진 최대 20장까지 허용
    const newParts = await Promise.all(
      newImageUrls.slice(0, 20).map((url) => urlToGenerativePart(url))
    );
    // [V3.1 Full Inspection] 원본 사진은 가능한 모든 이미지를 참조하여 비교에 사용
    const originalParts = await Promise.all(
      (Array.isArray(originalImageUrls) ? originalImageUrls : []).map((url) => urlToGenerativePart(url))
    );

    const contents = [
      { role: "user", parts: [
        { text: verificationPrompt },
        { text: "--- [PACKET A: ORIGINAL ITEM] (Reference) ---" },
        ...originalParts,
        { text: "--- [PACKET B: ON-SITE ITEM] (To Verify) ---" },
        ...newParts,
      ]},
    ];

    // 4. Gemini API 호출
    const rawResponseText = await genAiCall(genAI, {
      contents,
      safetySettings,
      responseMimeType: "application/json",
      tag: "verifyProductOnSite",
    });

    // 5. 결과 파싱 및 반환
    const jsonText = extractJsonText(rawResponseText);
    const verificationResult = tryParseJson(jsonText);
    logAiDiagnostics("verifyProductOnSite", rawResponseText, verificationResult);

    // [Task 110] AI가 'match' 키를 반환하지 못했을 때 (AI 실패)
    // - 'match: false'(불일치)가 아닌 'match: null'(판단 불가)을 반환하여
    //   앱이 재시도할 기회를 주도록 수정합니다.
    // - 이때 HTTP 에러를 던지지 않고 { success: true, verification: {...} }를 반환하여
    //   클라이언트가 "AI 실패 → 재시도" UI를 노출할 수 있게 합니다.
    if (!verificationResult || verificationResult.match === undefined) {
      logger.error(
        "❌ CRITICAL: AI verifyProductOnSite response is missing 'match' key. Returning fallback.",
        { keys: Object.keys(verificationResult || {}) }
      );

      /** [V3 3-Way Logic]
       * fallbackResult.match:
       *  - null : AI가 판단 불가(네트워크 오류, 포맷 불일치 등)
       *           → 클라이언트에서 "AI 실패, 재시도"로 처리
       */
      const fallbackResult = {
        match: null,
        reason: `AI 검증에 실패했습니다. 네트워크를 확인하고 다시 시도해 주세요. (${langName})`,
      };

      return { success: true, verification: fallbackResult };
    }

    // ---------------------------------------------------------
    // [V3.1 UPDATE] ai_cases (Takeover) 문서 생성 및 제품 이력 연결
    // ---------------------------------------------------------
    const isMatch = verificationResult.match === true;
    const caseRef = db.collection("ai_cases").doc();
    const caseId = caseRef.id;
    const now = FieldValue.serverTimestamp();

      const aiCaseData = {
      caseId: caseId,
      productId: productId,
      // [Fix] 데이터 불일치 해결: products의 'userId' 값을 ai_cases의 'sellerId'로 매핑
      sellerId: productData.userId || productData.sellerId || "unknown",
      buyerId: request.auth.uid, // 인수자 기록
      stage: "takeover",
      status: isMatch ? "pass" : "fail",
      evidenceImageUrls: newImageUrls, // 현장 증거 사진 영구 보존
      aiResult: JSON.parse(JSON.stringify(verificationResult)), // [Fix] undefined 값 제거 (Firestore 저장 에러 방지)
      verdict: isMatch ? "match_confirmed" : "match_failed",
      createdAt: now,
    };

    const batch = db.batch();
    batch.set(caseRef, aiCaseData);

    // 제품 상태 업데이트 (검증 이력 연결)
    batch.update(productRef, {
      lastAiCaseId: caseId,
      lastAiVerdict: aiCaseData.verdict,
      aiVerificationStatus: isMatch ? 'takeover_verified' : 'suspicious',
    });

    await batch.commit();

    logger.info(`✅ [AI 인수 2단계] 검증 완료: ${productId}`, verificationResult);
    return { success: true, verification: verificationResult, caseId: caseId };

  } catch (error) {
    logger.error("❌ AI Takeover Failed", error);
    // 전달하는 메시지는 안전하게 추출
    const errMsg = (error && error.message) || String(error || "unknown error");
    if (error instanceof HttpsError) throw error;
    throw new HttpsError("internal", `현장 검증 실패: ${errMsg}`, error);
  }
});
