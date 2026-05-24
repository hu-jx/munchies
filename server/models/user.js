//modules
import { Schema, model } from 'mongoose'

//schema 
const userSchema = new Schema({
    firebase_uid: {
        type: String,
        required: true,
        unique: true,
        index: true
    },

    username: {
        type: String,
        required: true,
        unique: true,
        trim: true,
        lowercase: true
    },

    firstName: {
        type: String,
        required: true,
        trim: true
    },

    emailAddress: {
        type: String,
        required: false,
        unique: true,
        default: null,
        trim: true,
        lowercase: true
    },
    lastName: {
        type: String,
        required: false,
        default: null,
        trim: true
    }
},
    {
        timestamps: true
    }
)

export const User = model('User', userSchema)
