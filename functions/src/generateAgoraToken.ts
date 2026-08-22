import * as functions from "firebase-functions";
import { RtcTokenBuilder, RtcRole } from "agora-access-token";

export const generateAgoraToken = functions.https.onCall(async (data, context) => {
  // Must be a signed-in user
  if (!context.auth) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "You must be signed in to join a session."
    );
  }

  const channelName: string = data.channelName;
  if (!channelName) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "channelName is required."
    );
  }

  // Read the secrets you just set
  const APP_ID: string = functions.config().agora.app_id;
  const APP_CERTIFICATE: string = functions.config().agora.app_certificate;

  const uid = 0; // 0 = Agora auto-assigns UID
  const expirationSeconds = 3600; // token valid for 1 hour
  const expireTimestamp = Math.floor(Date.now() / 1000) + expirationSeconds;

  const token = RtcTokenBuilder.buildTokenWithUid(
    APP_ID,
    APP_CERTIFICATE,
    channelName,
    uid,
    RtcRole.PUBLISHER,
    expireTimestamp
  );

  return { token };
});