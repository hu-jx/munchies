import { Schema, model, mongoose } from 'mongoose'

const recommendationsSchema = new Schema(
    {
        user_mongo_id: {
            type: Schema.Types.ObjectId,
            required: true,
            trim: true,
            immutable: true,
            ref: 'User',
        },

        user_firebase_uid: {
            type: String,
            required: true,
            unique: true,
            trim: true,
            immutable: true
        },

        recommendation: {
            tastePreference: String,
            recommendations: [
                {
                    _id: false,
                    name: String,
                    flavours: String,
                    benefit: String
                }

            ]
        },
    },
    { timestamps: true }
);

export const Recommendations = model('Recommendations', recommendationsSchema)