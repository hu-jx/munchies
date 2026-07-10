import { Schema, model, mongoose } from "mongoose";

const scheduledNotifsSchema = new Schema({
    user_mongo_id: {
        type: Schema.Types.ObjectId,
        required: true,
        trim: true,
        immutable: true,
        ref: 'User',
    },

    firebase_uid: {
        type: String,
        required: true,
    },

    sendAt: {
        type: Date,
        required: true,
    },

    sent: { 
        type: Boolean, 
        default: false 
    }

})

export const ScheduledNotifs = model('ScheduledNotifs', scheduledNotifsSchema)