const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

exports.deleteUser = functions.https.onCall(async (data, context) => {
  // רק אדמין מורשה יכול לקרוא לפונקציה
  if (!context.auth || !context.auth.token.admin) {
    throw new functions.https.HttpsError('permission-denied', 'Only admins can delete users');
  }
  const uid = data.uid;
  try {
    // 1. מחיקה מ-Auth
    await admin.auth().deleteUser(uid);
    // 2. מחיקה מה־Firestore (אם רוצה גם פה)
    await admin.firestore().collection('users').doc(uid).delete();
    return { success: true };
  } catch (e) {
    throw new functions.https.HttpsError('unknown', e.message, e);
  }
});
