import { Schema, mongoose } from 'mongoose'

//schema 
const recordSchema = new Schema({
    user_id: {
        type: Schema.Types.ObjectId,
        ref: 'User',
        required: true
    },

    item_name: {
        type: String,
        required: true,
        trim: true,
    },

    date: {
        type: Date, 
        required: true
    },

    //stored in cents in database
    cost: {
        type: int,
        required: true
    },

    photo: {
        type: Image,
        required: false
    },
},
    {
        timestamps: true
    }
)

export const Record = model('Record', recordSchema)