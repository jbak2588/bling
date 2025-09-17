/**
 * ============================================================================
 * Bling DocHeader (2nd Gen)
 * Module        : Auth, Trust, AI Verification
 * File          : functions-v2/index.js
 * Purpose       : 사용자 신뢰도 계산 및 AI 이미지 검증을 처리합니다.
 * Triggers      : Firestore onUpdate `users/{userId}`, HTTPS onCall
 * Data Access   : `users/{userId}`의 `thanksReceived`, `reportCount`, `profileCompleted`, `phoneNumber`, `locationParts`를 읽고 `trustScore`, `trustLevel`을 갱신합니다.
 * Monetization  : 높은 신뢰도는 마켓플레이스와 광고 참여 자격을 부여합니다.
 * KPIs          : 분석을 위해 `update_trust_level` 이벤트를 수집합니다.
 * Observability : `functions.logger`를 사용하며 오류는 Cloud Logging에 의존합니다.
 * Security      : Admin SDK는 서비스 계정이 필요하며 Firestore 규칙이 쓰기를 보호합니다.
 * Changelog     : 2025-08-26 DocHeader 최초 삽입(자동)
 * Source Docs   : docs/index/3 사용자 DB & 신뢰 등급.md; docs/team/TeamA_Auth_Trust_module_통합 작업문서.md
 * ============================================================================
 */
// 아래부터 실제 코드

// 2세대 SDK에서 필요한 모듈을 가져옵니다.

const { onCall, HttpsError } = require("firebase-functions/v2/https");
const { onDocumentUpdated } = require("firebase-functions/v2/firestore");
const { initializeApp } = require("firebase-admin/app");
const { getFirestore } = require("firebase-admin/firestore");
const vision = require("@google-cloud/vision");
const logger = require("firebase-functions/logger");

// Admin SDK & Vision Client
initializeApp();
const visionClient = new vision.ImageAnnotatorClient();

/* -------------------------------------------------------------------------- */
/*  0) 핑 함수(네트워크/프로젝트/이름/리전 즉시 확인용)                      */
/* -------------------------------------------------------------------------- */
exports.ping = onCall(
  { region: "us-central1", enforceAppCheck: false },
  (request) => {
    logger.info("ping: ENTER", { uid: request.auth?.uid ?? null });
    return {
      ok: true,
      uid: request.auth?.uid ?? null,
      ts: new Date().toISOString(),
    };
  }
);

/* -------------------------------------------------------------------------- */
/*  1) AI 검수 요청 (Vision)                                                  */
/*      - 타이밍 로그: ENTER / INPUT_READY / Vision REQUEST_START /           */
/*                    Vision RESPONSE_RECEIVED / RETURN                        */
/*      - 트러블슈팅 단계: enforceAppCheck: false (테스트용)                  */
/* 참고: 테스트 중 임시 완화가 필요하면 위 첫 줄의 enforceAppCheck: true 를 false */
/* 로만 바꿔 배포했다가, 통신 확인 후 다시 true로 복구하세요.                      */
/* -------------------------------------------------------------------------- */
exports.onAiVerificationRequest = onCall(
  { region: "us-central1", enforceAppCheck: true },
  async (request) => {
    const t0 = Date.now();
    logger.info("onAiVerificationRequest: ENTER", {
      uid: request.auth?.uid ?? null,
      hasData: !!request.data,
      len: (request.data?.imageBase64 || "").length,
    });

    // 1) 로그인 강제
    if (!request.auth) {
      throw new HttpsError(
        "unauthenticated",
        "The function must be called while authenticated."
      );
    }

    // 2) 입력 검증 + data URL 프리픽스 제거
    const imageBase64Raw = request.data?.imageBase64;
    if (!imageBase64Raw) {
      throw new HttpsError(
        "invalid-argument",
        "The function must be called with an 'imageBase64' argument."
      );
    }
    const imageBase64 = String(imageBase64Raw).replace(
      /^data:image\/\w+;base64,/,
      ""
    );
    logger.info("onAiVerificationRequest: INPUT_READY", {
      base64Length: imageBase64.length,
      ms: Date.now() - t0,
    });

    try {
      // 3) Vision 요청
      const visionRequest = [
        {
          image: { content: imageBase64 }, // base64 문자열 그대로
          features: [
            { type: "LABEL_DETECTION", maxResults: 5 },
            { type: "LOGO_DETECTION", maxResults: 5 },
            { type: "TEXT_DETECTION" },
            { type: "SAFE_SEARCH_DETECTION" },
          ],
        },
      ];

      logger.info("Vision: REQUEST_START");
      const [result] = await visionClient.batchAnnotateImages({
        requests: visionRequest,
      });
      logger.info("Vision: RESPONSE_RECEIVED", { ms: Date.now() - t0 });

      // 4) 응답 파싱
      const responsesArr = result?.responses ?? [];
      if (responsesArr.length === 0) {
        logger.error("Vision: EMPTY_RESPONSE", {
          resultKeys: Object.keys(result || {}),
        });
        throw new HttpsError(
          "internal",
          "Vision API returned an empty response."
        );
      }
      const responses = responsesArr[0];

      if (responses.error) {
        logger.error("Vision: RESPONSE_ERROR", responses.error);
        throw new HttpsError(
          "internal",
          `Vision API Error: ${responses.error.message}`
        );
      }

      // 5) 정책 검사 & 요약
      const safeSearch = responses.safeSearchAnnotation || {};
      if (
        safeSearch.adult === "VERY_LIKELY" ||
        safeSearch.violence === "VERY_LIKELY"
      ) {
        logger.warn("Policy: BLOCKED_BY_SAFESEARCH", safeSearch);
        throw new HttpsError(
          "permission-denied",
          "Inappropriate image content detected."
        );
      }

      const labels = responses.labelAnnotations || [];
      const logos = responses.logoAnnotations || [];
      const texts = responses.textAnnotations || [];

      const aiReport = {
        detectedCategory: labels[0]?.description ?? "Unknown",
        detectedBrand: logos[0]?.description ?? "Unknown",
        detectedFeatures: texts.slice(1, 6).map((t) => t.description),
        priceSuggestion: { min: 10000, max: 50000 },
        damageReports: [],
        lastInspected: new Date().toISOString(),
      };

      logger.info("onAiVerificationRequest: RETURN", {
        ms: Date.now() - t0,
        hasLabels: labels.length > 0,
        hasLogos: logos.length > 0,
        hasText: texts.length > 0,
      });

      return aiReport;
    } catch (error) {
      logger.error("onAiVerificationRequest: ERROR", {
        message: error?.message,
        code: error?.code,
        stack: error?.stack,
      });
      if (error instanceof HttpsError) throw error;
      const message = (error?.message || "Vision error").slice(0, 300);
      throw new HttpsError("internal", "Vision failed", { message });
    }
  }
);

/* -------------------------------------------------------------------------- */
/*  2) 사용자 프로필 업데이트 시 신뢰 점수 계산 (2nd Gen Firestore)            */
/* -------------------------------------------------------------------------- */
exports.calculateTrustScore = onDocumentUpdated(
  "users/{userId}",
  async (event) => {
    const userData = event.data.after.data();
    const previousUserData = event.data.before.data();
    const userId = event.params.userId;

    const mainFieldsUnchanged =
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

    // 점수 계산 로직
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
        `Updating user ${userId}: New Score = ${finalScore}, New Level = ${level}`
      );
      return getFirestore().collection("users").doc(userId).update({
        trustScore: finalScore,
        trustLevel: level,
      });
    }

    return null;
  }
);