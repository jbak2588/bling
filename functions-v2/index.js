/**
 * ============================================================================
 * Bling DocHeader
 * Module        : Auth & Trust
 * File          : functions-v2/index.js
 * Purpose       : 프로필 업데이트 시 사용자 신뢰 점수를 계산합니다.
 * Triggers      : Firestore onUpdate `users/{userId}`
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


const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

exports.calculateTrustScore = functions.firestore
    .document("users/{userId}")
    .onUpdate(async (change, context) => {
      const userData = change.after.data();
      const previousUserData = change.before.data();

      const mainFieldsUnchanged =
        userData.thanksReceived === previousUserData.thanksReceived &&
        userData.reportCount === previousUserData.reportCount &&
        userData.profileCompleted === previousUserData.profileCompleted &&
        userData.phoneNumber === previousUserData.phoneNumber &&
        JSON.stringify(userData.locationParts) ===
          JSON.stringify(previousUserData.locationParts);

      if (mainFieldsUnchanged) {
        functions.logger.info("No score-related changes, exiting.");
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

      if (
        finalScore !== userData.trustScore ||
        level !== userData.trustLevel
      ) {
        functions.logger.info(
            // eslint-disable-next-line max-len
            `Updating user ${context.params.userId}: New Score = ${finalScore}, New Level = ${level}`,
        );
        return change.after.ref.update({
          trustScore: finalScore,
          trustLevel: level,
        });
      }

      functions.logger.info("No score or level change needed.");
      return null;
    });
