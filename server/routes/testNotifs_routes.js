// routes/testNotification.js (or wherever your routes live)
import express from 'express';
import admin from 'firebase-admin';

const testNotifRouter = express.Router();

testNotifRouter.post('/test-notification', async (req, res) => {
  const { token } = req.body;

  if (!token) {
    return res.status(400).json({ error: 'Missing token in request body' });
  }

  try {
    const response = await admin.messaging().send({
      token,
      notification: {
        title: 'Test notification',
        body: 'If you see this, the pipeline works!'
      }
    });

    console.log('FCM send success:', response);
    return res.status(200).json({ success: true, messageId: response });

  } catch (err) {
    console.error('FCM send error:', err.code, err.message);
    return res.status(500).json({
      success: false,
      errorCode: err.code,
      errorMessage: err.message
    });
  }
});

export default testNotifRouter;