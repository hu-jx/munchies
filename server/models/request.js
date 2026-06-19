import { Schema, model } from 'mongoose'

const requestSchema = new Schema({

    sender_id: {
        type: Schema.Types.ObjectId,
        required: true,
    },

    receiver_id: {
        type: Schema.Types.ObjectId,
        required: true,
    },

    //pending, accepted, declined
    status: {
        type: String,
        enum: ['pending', 'accepted', 'declined'],
        default: 'pending',
    }

},
    {
        timestamps: true
    }
)

export const Request = model('Request', requestSchema)