import cron from "node-cron"
import admin from 'firebase-admin';
import { User } from "../models/user.js"
import { Record } from "../models/record.js"

export async function sendNotif(user) {
    try {
        const response = await admin.messaging().send({
            token: user.fcmToken,
            notification: {
                title: 'Log your sweet treats now 🍽️',
                body: 'Don\'t forget to log your treats today!'
            }
        });

        console.log('FCM send success:', response);
    } catch (e) {
        console.error('FCM send error:', e.message);
        if (e.code === 'messaging/registration-token-not-registered') {
            await User.findOneAndUpdate(
                { fcmToken: user.fcmToken },
                { fcmToken: null }
            );
            console.log('Cleared stale token for user', user._id);
        }
    }
}

function scheduleNotifs(user, count) {
    //const msPerWeek = 24 * 60 * 60 * 1000
    //msPerWeek for TESTING PURPOSES
    const msPerWeek = 5 * 60 * 1000;
    //add 1 to deal with the case that count is 0
    const intervals = msPerWeek / (count + 1)

    for (let i = 1; i <= count; i++) {
        setTimeout(() => sendNotif(user), intervals * i);
    }
    console.log('Set notifications for the week')
}

export async function startScheduling(req, res) {
    //THIS VER IS FOR TESTING
    cron.schedule('40 22 * * *', async () => {
    // cron.schedule('0 18 * * 0', async () => {
        console.log('Weekly scheduling initiated:', new Date().toISOString());

        const prevWeek = new Date(Date.now() - 7 * 24 * 60 * 60 * 1000)

        //get the users with "registered" devices to send notifs to
        const users = await User.find({ fcmToken: { $ne: null } })

        for (const user of users) {
            try {
                const count = await Record.countDocuments({
                    user_uid: user.firebase_uid,
                    createdAt: { $gte: prevWeek }
                })
                const notifCount = Math.max(1, Math.floor(count / 2))
                console.log('Count for the past week:', notifCount);
                scheduleNotifs(user, notifCount);
            } catch (e) {
                console.error(`Failed processing user ${user._id}:`, e);
            }
        }
    })
}