import cron from "node-cron"
import admin from 'firebase-admin';
import { User } from "../models/user.js"
import { Record } from "../models/record.js"
import { ScheduledNotifs } from "../models/scheduledNotifs.js";

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

async function scheduleNotifs(user, count) {
    const msPerWeek = 24 * 60 * 60 * 1000
    const intervals = msPerWeek / (count + 1)

    for (let i = 1; i <= count; i++) {
        const sendAt = new Date(Date.now() + intervals * i);
        await ScheduledNotifs.create({
            user_mongo_id: user._id,
            firebase_uid: user.firebase_uid,
            sendAt: sendAt,
        })
    }
    console.log('Set notifications for the week')
}

export async function startScheduling(req, res) {
    cron.schedule('6 0 * * *', async () => {
        await runWeeklyScheduling();
    })

    cron.schedule('*/5 * * * *', async () => {
    const scheduledNow = await ScheduledNotifs.find({
        sendAt: { $lte: new Date() },
        sent: false,
    })

    for (const notif of scheduledNow) {
        try {
            const user = await User.findOne(
                { firebase_uid: notif.firebase_uid }
            )

            if (!user?.fcmToken) {
                notif.sent = true;
                await notif.save();
                continue;
            }

            await sendNotif(user);
            notif.sent = true;
            await notif.save();

            console.log('Sent scheduled notification to user', user.firebase_uid)

        } catch (e) {
            console.error('FAILED TO SEND SCHEDULED NOTIF')
            notif.sent = true;
            await notif.save();
        }

    }

})
}

export async function runWeeklyScheduling() {
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
                await scheduleNotifs(user, notifCount);
            } catch (e) {
                console.error(`Failed processing user ${user._id}:`, e);
            }
        }
}

