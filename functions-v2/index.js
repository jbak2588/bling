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
