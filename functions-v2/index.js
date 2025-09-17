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
 * : 2025-09-16 AI 검증 함수에 동적 가격 분석 로직 추가 (axios, cheerio)
 * : 2025-09-17 ChatGPT 분석에 따라 Vision API 응답 파싱 버그 및 `const` 재할당 오류 수정.
 * : 2025-09-17 요청:19 분석에 따라 `ok is not defined` 버그 수정 및 안정성 강화.
 * Source Docs   : docs/index/3 사용자 DB & 신뢰 등급.md; docs/team/TeamA_Auth_Trust_module_통합 작업문서.md
 * ============================================================================
 */

// 2세대 SDK에서 필요한 모듈을 가져옵니다.
const { onCall, HttpsError } = require("firebase-functions/v2/https");
const { onDocumentUpdated } = require("firebase-functions/v2/firestore");
const { initializeApp } = require("firebase-admin/app");
const { getFirestore } = require("firebase-admin/firestore");
const vision = require("@google-cloud/vision");
const logger = require("firebase-functions/logger");

// ✅ 웹 요청(axios) 및 HTML 분석(cheerio) 라이브러리 추가
const axios = require("axios");
const cheerio = require("cheerio");

// Admin SDK & Vision Client 초기화
initializeApp();
const visionClient = new vision.ImageAnnotatorClient();

/* -------------------------------------------------------------------------- */
/* AI 검수 요청 (Vision API & Dynamic Price Scraping)                      */
/* -------------------------------------------------------------------------- */
/**
 * @description App Check로 앱 무결성을 검증하고, Vision API로 이미지를 분석하며,
 * Google 검색 결과를 스크래핑하여 동적 가격을 제안합니다.
 */
exports.onAiVerificationRequest = onCall({ region: "us-central1", enforceAppCheck: true }, async (request) => {
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
    // [수정 기록] ChatGPT 분석: `const` 재할당 오류를 피하기 위해 원본(Raw)과 가공 후 변수를 분리.
    const imageBase64Raw = request.data?.imageBase64;
    if (!imageBase64Raw) {
      throw new HttpsError(
        "invalid-argument",
        "The function must be called with an 'imageBase64' argument."
      );
    }
    const imageBase64 = String(imageBase64Raw).replace(/^data:image\/\w+;base64,/, "");
    
    logger.info("onAiVerificationRequest: INPUT_READY", {
      base64Length: imageBase64.length,
      ms: Date.now() - t0,
    });

    try {
      // 3) Vision API 요청
      const visionRequest = [{
        image: { content: imageBase64 },
        features: [
            { type: "LABEL_DETECTION", maxResults: 5 },
            { type: "LOGO_DETECTION", maxResults: 5 },
            { type: "TEXT_DETECTION" },
            { type: "SAFE_SEARCH_DETECTION" },
        ],
      }];
      
      logger.info("Vision: REQUEST_START");
      const [result] = await visionClient.batchAnnotateImages({ requests: visionRequest });
      logger.info("Vision: RESPONSE_RECEIVED", { ms: Date.now() - t0 });

      // 4) Vision API 응답 파싱
      // [수정 기록] ChatGPT 분석: API의 실제 응답 필드명은 `imageResponses`가 아닌 `responses`임.
      const responsesArr = result.responses ?? [];
      if (responsesArr.length === 0) {
        logger.error("Vision: EMPTY_RESPONSE", { resultKeys: Object.keys(result || {}) });
        throw new HttpsError("internal", "Vision API returned an empty response.");
      }
      const responses = responsesArr[0];
      if (responses.error) {
        logger.error("Vision: RESPONSE_ERROR", responses.error);
        throw new HttpsError("internal", `Vision API Error: ${responses.error.message}`);
      }

      // 5) 정책 검사 & 분석 결과 요약
      const safeSearch = responses.safeSearchAnnotation || {};
      if (safeSearch.adult === "VERY_LIKELY" || safeSearch.violence === "VERY_LIKELY") {
        logger.warn("Policy: BLOCKED_BY_SAFESEARCH", safeSearch);
        throw new HttpsError("permission-denied", "Inappropriate image content detected.");
      }

      const labels = responses.labelAnnotations || [];
      const detectedCategory = labels.length > 0 ? labels[0].description : null;
      
      const logos = responses.logoAnnotations || [];
      const detectedBrand = logos.length > 0 ? logos[0].description : null;
      
      const textAnnotations = responses.textAnnotations || [];
      const detectedFeatures = textAnnotations.slice(1, 6).map((ann) => ann.description);
      
      // ✅ [수정 기록] 요청:19 분석: `ok` is not defined 버그를 해결하기 위해
      // 가격 분석 로직을 함수 내부에 통합하고 안정성을 강화함.
      let priceSuggestion = { min: 10000, max: 50000 };
      if (detectedBrand && detectedCategory) {
        const searchQuery = `harga bekas ${detectedBrand} ${detectedCategory} site:tokopedia.com OR site:olx.co.id`;
        const searchUrl = `https://www.google.com/search?q=${encodeURIComponent(searchQuery)}&hl=id`;
        try {
          const { data } = await axios.get(searchUrl, {
            headers: { "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36" },
          });
          const $ = cheerio.load(data);
          const prices = [];
          $("body").find("*").each(function () {
            $(this).contents().filter(function () {
              return this.type === "text" && $(this).text().includes("Rp");
            }).each(function () {
              const text = $(this).text();
              const priceMatches = text.match(/Rp\s*[\d.,]+/g);
              if (priceMatches) {
                priceMatches.forEach((match) => {
                  const price = parseInt(match.replace(/Rp|\.|,/g, "").trim(), 10);
                  if (!isNaN(price) && price > 1000) {
                    prices.push(price);
                  }
                });
              }
            });
          });
          if (prices.length > 0) {
            priceSuggestion = { min: Math.min(...prices), max: Math.max(...prices) };
          }
        } catch (scrapeError) {
          logger.error("Web scraping for price failed:", scrapeError.message);
        }
      }

      // 6) 최종 분석 리포트 생성
      const aiReport = {
        detectedCategory: detectedCategory ?? "Unknown",
        detectedBrand: detectedBrand ?? "Unknown",
        detectedFeatures,
        priceSuggestion,
        damageReports: [],
        lastInspected: new Date().toISOString(),
      };
      
      logger.info("onAiVerificationRequest: RETURN", { ms: Date.now() - t0 });
      return aiReport;

    } catch (error) {
      logger.error("onAiVerificationRequest: ERROR", {
        message: error?.message,
        code: error?.code,
        stack: error?.stack,
        details: error?.details,
      });
      if (error instanceof HttpsError) throw error;
      const message = (error?.message || "Vision error").slice(0, 300);
      throw new HttpsError("internal", "Vision failed", { message });
    }
  }
);


/* -------------------------------------------------------------------------- */
/* 사용자 프로필 업데이트 시 신뢰 점수 계산 (2nd Gen Firestore)              */
/* -------------------------------------------------------------------------- */
exports.calculateTrustScore = onDocumentUpdated("users/{userId}", async (event) => {
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