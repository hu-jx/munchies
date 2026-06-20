//modules
import { Schema, model, mongoose } from 'mongoose'

//schema 
const userSchema = new Schema({
    firebase_uid: {
        type: String,
        required: true,
        unique: true,
    },

    emailAddress: {
        type: String,
        required: true,
        unique: true,
        default: null,
        trim: true,
        lowercase: true
    },

    firstName: {
        type: String,
        required: true,
        trim: true
    },

    lastName: {
        type: String,
        required: false,
        default: null,
        trim: true
    },

    friends: {
        type: [{ type: mongoose.Schema.Types.ObjectId, ref: 'User' }],
        required: false,
        default: []
    },
},
    {
        timestamps: true
    }
)

export const User = model('User', userSchema)
