import { MongoMemoryServer } from 'mongodb-memory-server';
import mongoose from 'mongoose';
import { User } from '../models/user';
import { Record } from '../models/record';
import { ScheduledNotifs } from '../models/scheduledNotifs';
import { runWeeklyScheduling } from '../utils/notif_schedular';

let mongoServer;

beforeAll(async () => {
    mongoServer = await MongoMemoryServer.create();
    await mongoose.connect(mongoServer.getUri());
})

afterAll(async () => {
    await mongoose.disconnect();
    await mongoServer.stop();
})

test('', async () => {
    const user = await User.create({
        firebase_uid: "test_firebase_uid",
        fcmToken: "test_fcm_token",
        firstName: "testing",
        emailAddress: "notif_test@gmail.com"
    });

    await Record.create([
        { user_uid: 'test_firebase_uid', createdAt: new Date(), cost: "100", itemName: "test item 1", user_mongo_id: user._id },
        { user_uid: 'test_firebase_uid', createdAt: new Date(), cost: "100", itemName: "test item 2", user_mongo_id: user._id },
        { user_uid: 'test_firebase_uid', createdAt: new Date(), cost: "100", itemName: "test item 3", user_mongo_id: user._id },
        { user_uid: 'test_firebase_uid', createdAt: new Date(), cost: "100", itemName: "test item 4", user_mongo_id: user._id },
    ])

    await runWeeklyScheduling();

    const scheduled = await ScheduledNotifs.find({ user_mongo_id: user._id });

    expect(scheduled.length).toBe(2);
});
