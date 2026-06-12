import { Int32 } from 'mongodb'
import { Schema, model } from 'mongoose'

//schema 
const recordSchema = new Schema({
    user_uid: {
        type: String,
        required: true,
        unique: true,
        trim: true,
        immutable: true
    },

    itemName: {
        type: String,
        required: true,
        trim: true,
    },

    date: {
        type: Date, 
        required: true,
        default: new Date(Date.now())
    },

    //stored in cents in database
    cost: {
        type: Int32,
        required: true
    },

    //convert to Base64 for use
    photo: {
        type: Buffer,
        required: false,
        default: null
    },
    
    category: {
        type: String,
        required: false,
        default: null,
        trim: true
    },

    isFavourited: {
        type: Boolean,
        required: true,
        default: false,
        immutable: false
    },

    details: {
        type: String,
        required: false,
        trim: true
    },

    isVisible: {
        type: Boolean,
        required: true,
        default: false,
        immutable: false
    }
},
    {
        timestamps: true
    }
)

export const Record = model('Record', recordSchema)