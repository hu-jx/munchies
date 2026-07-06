import { Record } from "../models/record.js"
import mongoose from 'mongoose'
import { config } from 'dotenv';
import { User } from '../models/user.js';
import { Recommendations } from "../models/recommendations.js";
import { ApiError, GoogleGenAI } from "@google/genai";

export async function findRecommendation(req, res) {
    try {
        const currentUser = await User.findOne(
            {
                firebase_uid: req.uid,
            })
        const rec = await Recommendations.findOne({ user_firebase_uid: currentUser.firebase_uid })
        const DAY_IN_MS = 24 * 60 * 60 * 1000;

        //check the recommendations record for the user_uid is present AND not expired time now - updatedAt > 24h)
        if (rec && (Date.now() - rec.updatedAt.getTime() < DAY_IN_MS)) {
            console.log("Returning cached recommendation");
            return res.status(200).json(rec.recommendation);
        }

        //else create a new one and add it into recommendations
        const newRec = await getNewRecommendation(currentUser.firebase_uid)

        if (!newRec) {
            return res.status(200).json({ message: 'Not enough data, or Gemini API error occured' })
        }

        await Recommendations.findOneAndUpdate(
            { user_firebase_uid: currentUser.firebase_uid },
            { recommendation: newRec },
            { upsert: true },
        )

        return res.status(200).json(newRec);

    } catch (e) {
        console.log("Find recommendations error: " + e)
        return res.status(500).json({ message: "Server error" })
    }
}

async function getNewRecommendation(firebase_uid) {
    //query to get the most frequently consumed food and top categories
    const topItems = await Record.aggregate(
        [
            {
                $match: {
                    user_uid: firebase_uid
                },
            },
            {
                //group by category/item name, then sort, then limit top 3
                $group: {
                    _id: "$itemName",
                    itemCount: { $sum: 1 }
                }
            },
            {
                $sort: {
                    itemCount: -1
                }
            },
            {
                $limit: 5
            }
        ]
    )

    const topCategory = await Record.aggregate(
        [
            {
                $match: {
                    user_uid: firebase_uid
                },
            },
            {
                //group by category/item name, then sort, then limit top 3
                $group: {
                    _id: "$category",
                    categoryCount: { $sum: 1 }
                }
            },
            {
                $sort: {
                    categoryCount: -1
                }
            },
            {
                $limit: 3
            }
        ]
    )

    if (topItems.length == 0 || topCategory.length == 0) {
        return null;
    }

    const prompt = `
    This is the consumption data of a user of a sweet treat tracker.

    Top 5 categories consumed: ${JSON.stringify(topCategory.map(cat => cat._id))}
    Top 5 item names inputted by the user: ${JSON.stringify(topItems.map(item => item._id))}

    Ignore any null categories. Ignore item names that appear to not be food items.

    Based on this data, do two things:
    1. Identify the overall taste preferences of the user
    2. Recommend exactly 3 other healthier choices with a similar taste profile
    
    Respond with ONLY JSON, return the data in this JSON format:
    {
        "tastePreference": "We noticed that you enjoy [describe taste preference here]. Keep it to a maximum of 15 words",
        "recommendations": [
            { "name": "name of healthier alternative treat", "flavours": "a maximum of 6 descriptive words about texture/flavour", "benefit": "concise sentence on why it is healthier, max 10 words" },
            { "name": "name of healthier alternative treat", "flavours": "a maximum of 6 descriptive words about texture/flavour", "benefit": "concise sentence on why it is healthier, max 10 words" },
            { "name": "name of healthier alternative treat", "flavours": "a maximum of 6 descriptive words about texture/flavour", "benefit": "concise sentence on why it is healthier, max 10 words" },
        ]
    }
    `;

    const GEMINI_API_KEY = process.env.GEMINI_API_KEY
    const ai = new GoogleGenAI({ apiKey: GEMINI_API_KEY });

    console.log("API key present?", !!process.env.GEMINI_API_KEY);


    let parsed = null;
    let prevError = null;
    for (let i = 1; i <= 3; i++) {
        try {
            const result = await ai.models.generateContent(
                {
                    model: "gemini-2.5-flash-lite",
                    contents: prompt,
                }
            )
            console.log("Full response:", JSON.stringify(result.text, null, 2));
            console.log(result.text);

            const text = result.text;
            const parsed = JSON.parse(text.replace(/```json|```/g, '').trim());
            return parsed;
        } catch (e) {
            prevError = e;
            console.log("Gemini attempt failed: " + e)
            if (i < 3) {
                await new Promise(resolve => setTimeout(resolve, 1000 * Math.pow(2, i - 1)))
            }
        }
    }

    throw new Error("All Gemini attempts failed");

};