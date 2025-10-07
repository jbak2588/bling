/**
 * ============================================================================
 * Bling DocHeader (v3.1 - Gemini Safety Settings)
 * Module        : Auth, Trust, AI Verification
 * File          : functions-v2/index.js
 * Purpose       : 사용자 신뢰도 계산 및 Gemini 기반의 AI 상품 분석을 처리합니다.
 * Triggers      : Firestore onUpdate `users/{userId}`, HTTPS onCall
 * ============================================================================
 */
const { onCall } = require("firebase-functions/v2/https");
const { onDocumentUpdated } = require("firebase-functions/v2/firestore");
const { initializeApp } = require("firebase-admin/app");
const { getFirestore } = require("firebase-admin/firestore");
const { logger } = require("firebase-functions");
const { GoogleGenerativeAI, HarmCategory, HarmBlockThreshold } = require("@google/generative-ai");

initializeApp();

const genAI = new GoogleGenerativeAI(process.env.GEMINI_KEY);

// [신규] Gemini 안전 설정: 유해성 기준이 '높음'일 경우에만 차단하도록 설정
const safetySettings = [
  {
    category: HarmCategory.HARM_CATEGORY_HARASSMENT,
    threshold: HarmBlockThreshold.BLOCK_ONLY_HIGH,
  },
  {
    category: HarmCategory.HARM_CATEGORY_HATE_SPEECH,
    threshold: HarmBlockThreshold.BLOCK_ONLY_HIGH,
  },
  {
    category: HarmCategory.HARM_CATEGORY_SEXUALLY_EXPLICIT,
    threshold: HarmBlockThreshold.BLOCK_ONLY_HIGH,
  },
  {
    category: HarmCategory.HARM_CATEGORY_DANGEROUS_CONTENT,
    threshold: HarmBlockThreshold.BLOCK_ONLY_HIGH,
  },
];

/**
 * [유지] 사용자 문서가 업데이트될 때 신뢰도 점수와 레벨을 다시 계산합니다.
 */
exports.calculateTrustScore = onDocumentUpdated("users/{userId}", async (event) => {
  const userData = event.data.after.data();
  const previousUserData = event.data.before.data();
  const userId = event.params.userId;

  if (!userData) {
    logger.info(`User data for ${userId} is missing.`);
    return null;
  }
  
  // (기존 코드와 동일)
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
});


/**
 * [수정] 1차 갤러리 이미지들을 기반으로 상품명을 예측합니다. (안전 설정 추가)
 */
exports.initialProductAnalysis = onCall(async (request) => {
  const { imageUrls } = request.data;
  if (!imageUrls || imageUrls.length === 0) {
    return { success: false, error: "No images provided." };
  }

  try {
    // [수정] getGenerativeModel 호출 시 safetySettings를 전달합니다.
    const model = genAI.getGenerativeModel({ model: "gemini-pro-vision", safetySettings });

    const prompt = "Based on these images, what is the specific brand and model name of this product? Provide only the name, without any extra text or labels.";

    const imageParts = await Promise.all(
      imageUrls.map(async (url) => {
        const response = await fetch(url);
        const buffer = await response.arrayBuffer();
        return {
          inlineData: {
            mimeType: response.headers.get('content-type') || 'image/jpeg',
            data: Buffer.from(buffer).toString("base64"),
          },
        };
      })
    );

    const result = await model.generateContent([prompt, ...imageParts]);
    const responseText = result.response.text().trim();

    return { success: true, prediction: responseText };

  } catch (error) {
    logger.error("initialProductAnalysis failed:", error.toString());
    return { success: false, error: "AI analysis failed." };
  }
});

/**
 * [수정] 모든 이미지와 정보를 종합하여 최종 판매 보고서를 생성합니다. (안전 설정 추가)
 */
exports.generateFinalReport = onCall(async (request) => {
  const { 
    imageUrls,
    ruleId,
    confirmedProductName, 
    userPrice, 
    userDescription 
  } = request.data;

  if (!imageUrls || !ruleId) {
    return { success: false, error: "Required data is missing." };
  }

  try {
    const db = getFirestore();
    const ruleDoc = await db.collection("ai_verification_rules").doc(ruleId).get();
    if (!ruleDoc.exists) {
      return { success: false, error: "Verification rule not found." };
    }
    let promptTemplate = ruleDoc.data().report_template_prompt;
    
    promptTemplate = promptTemplate.replace("{{userPrice}}", userPrice || "");
    promptTemplate = promptTemplate.replace("{{userDescription}}", userDescription || "");
    promptTemplate = promptTemplate.replace("{{confirmedProductName}}", confirmedProductName || "");

    // [수정] getGenerativeModel 호출 시 safetySettings를 전달합니다.
    const model = genAI.getGenerativeModel({ model: "gemini-pro-vision", safetySettings });
    
    const allImageUrls = [...imageUrls.initial, ...Object.values(imageUrls.guided)];
    const imageParts = await Promise.all(
      allImageUrls.map(async (url) => {
        const response = await fetch(url);
        const buffer = await response.arrayBuffer();
        return {
          inlineData: {
            mimeType: response.headers.get('content-type') || 'image/jpeg',
            data: Buffer.from(buffer).toString("base64"),
          },
        };
      })
    );
    
    const result = await model.generateContent([promptTemplate, ...imageParts]);
    const responseText = result.response.text();
    const cleanJsonText = responseText.replace(/```json|```/g, '').trim();

    const report = JSON.parse(cleanJsonText);
    return { success: true, report: report };

  } catch (error) {
    logger.error("Final report generation failed:", error.toString());
    return { success: false, error: "AI final report generation failed." };
  }
});