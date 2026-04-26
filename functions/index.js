const { onCall, HttpsError } = require("firebase-functions/v2/https");
const { initializeApp } = require("firebase-admin/app");
const { getFirestore } = require("firebase-admin/firestore");
const { getMessaging } = require("firebase-admin/messaging");

initializeApp();

exports.sendPushNotification = onCall(async (request) => {
  const { toUid, title, body, data } = request.data;

  if (!toUid || !title || !body) {
    throw new HttpsError("invalid-argument", "Missing required fields.");
  }

  // Get the recipient's FCM token from Firestore
  const db = getFirestore();
  const userDoc = await db.collection("users").doc(toUid).get();

  if (!userDoc.exists) {
    throw new HttpsError("not-found", "User not found.");
  }

  const fcmToken = userDoc.data()?.fcmToken;
  if (!fcmToken) {
    // User has no token yet — skip silently (in-app notif still saved)
    return { success: false, reason: "no_token" };
  }

  // Send the push notification
  await getMessaging().send({
    token: fcmToken,
    notification: { title, body },
    data: data || {},
    android: {
      priority: "high",
      notification: { sound: "default" },
    },
    apns: {
      payload: {
        aps: { sound: "default", badge: 1 },
      },
    },
  });

  return { success: true };
});