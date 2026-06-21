import { Int32 } from 'mongodb'
import { Schema, model, mongoose } from 'mongoose'

//schema 
const recordSchema = new Schema({
    user_mongo_id: {
        type: Schema.Types.ObjectId,
        required: true,
        trim: true,
        immutable: true
    },

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

    //save URL
    photo: {
        type: String,
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
    },

    likes: {
        type: [{ type: mongoose.Schema.Types.ObjectId, ref: 'User' }],
        required: false,
        default: [],
        immutable: false,
    }
},
    {
        timestamps: true
    }
)

export const Record = model('Record', recordSchema)