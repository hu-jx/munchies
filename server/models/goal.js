import { Int32 } from 'mongodb'
import { Schema, model } from 'mongoose'
//save start week here too -> don't have to recompute whenever streak is computed
//start_week = number of weeks from 2025-01-01 (no goal can be computed from prior to this)
const goalSchema = new Schema({
    user_uid: {
        type: String, 
        required: true,
        trim: true,
        immutable: true
    },
    quantity: {
        type: Int32,
        required: true
    }, 
    start_week: {
        type: Int32,
        required: true
    },
    isActive: {
        type: Boolean,
        required: true,
        default: false
    },
    start_date: {
        type: Date,
        required: true,
        default: new Date()
    }
}, 
{
        timestamps: false,
    })

export const Goal = model('Goal', goalSchema)