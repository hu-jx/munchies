import dayjs from 'dayjs'
import 'dayjs/locale/en-sg.js'
import { Record } from "../models/record.js"
import mongoose from 'mongoose'
import { config } from 'dotenv';
import { ApiError, GoogleGenAI } from "@google/genai";
import cloudinary from '../config/cloudinary.js'
import { extractPublicId } from 'cloudinary-build-url'
config({ quiet: true })
import fs from 'fs'
const ObjectId = mongoose.Types.ObjectId

dayjs.locale('en-sg')
//Create following CRUD 
export async function createRecord(req, res) {
    try {
        var { user_uid, itemName, date, cost, category, isFavourited, details, isVisible } = req.body
            //TODO: UPLOAD FILE ONTO CLOUDINARY INSTEAD
            // photo = Buffer.from(photo, 'base64')
        var url;
        if (req.file != null) {
            const { path } = req.file
            const photo = await cloudinary.uploader.upload(req.file.path, {folder: 'uploads'})
            url = photo.secure_url
            fs.unlinkSync(path)
        }
        const new_record = new Record({
            user_uid: user_uid,
            itemName: itemName,
            date: date,
            cost: cost,
            category: category,
            isFavourited: isFavourited,
            details: details,
            isVisible: isVisible,
            photo: url
        })
        await new_record.save()
        return res.status(201).json({ message: "Successfully created new record" })
    } catch (error) {
        console.error("createRecord error: ", error)
        return res.status(500).json({ message: "Server error occurred" })
    }
}


export async function getAllRecords(req, res) {
    try {
        var records_data_query;
        var query_params = req.query
        if (Object.keys(query_params).length !== 0) {
            records_data_query = filterRecords(records_data_query, query_params, req.uid)
        } else {
            records_data_query = Record.aggregate(
                [{
                    $match: {
                        user_uid: req.uid
                    }
                }]
            )
        }
        var records_data = await records_data_query.sort('-date -cost itemName')

        if (records_data.length == 0) {
            return res.status(204).json({ message: "No data found" })
        }
        // records_data = records_data.map((r) => {
        //     //TODO: JUST PASS URL OVER HERE. NO NEED FOR ANY DECODING OF BASE64
        //     const base64_photo = r.photo ? r.photo.toString('base64') : null;
        //     return {
        //         ...r,
        //         photo: base64_photo,
        //     };
        // });
        return res.status(200).json(records_data)
    } catch (error) {
        console.error("getAllRecords error: ", error)
        return res.status(500).json({ message: "Server error" })
    }
}

function filterRecords(query_records, query_params, user_uid) {
    //function only modifies the query, does not return new one 
    if ('favourites' in query_params) {
        var fav = false;
        if (query_params.favourites == 'true') {
            fav = true
        }
        return Record.aggregate([
            {
                $group: {
                    _id: {
                        itemName: "$itemName",
                        cost: "$cost"
                    },
                    document: {
                        $first: {
                            _id: '$_id',
                            user_uid: "$user_uid",
                            itemName: "$itemName",
                            date: "$date",
                            cost: "$cost",
                            isFavourited: "$isFavourited"
                        }
                    }
                }
            },
            {
                $match: {
                    "document.isFavourited": true
                }
            },
            {
                $project: {
                    _id: '$document._id',
                    user_uid: '$document.user_uid',
                    itemName: '$document.itemName',
                    date: '$document.date',
                    cost: '$document.cost',
                    isFavourited: '$document.isFavourited'
                }
            }
        ],
        );

    }
    else if ('freq' in query_params) {
        if (query_params.freq == 'today') {
            var sod = dayjs().startOf('day').toDate()
            var eod = dayjs().endOf('day').toDate()
            return Record.aggregate(
                [
                    {
                        $match: {
                            'user_uid': user_uid,
                            'date': { $gte: sod, $lte: eod }
                        }
                    }
                ]
            )
        } else if (query_params.freq == 'weekly') {
            var sow = dayjs().startOf('week').toDate()
            var eow = dayjs().endOf('week').toDate()
            return Record.aggregate(
                [
                    {
                        $match: {
                            'user_uid': user_uid,
                            'date': { $gte: sow, $lte: eow }
                        }
                    }
                ]
            )
        }
    }
    else if ('month' in query_params && 'year' in query_params) {
        var req_month = query_params.month - 1
        var year = query_params.year
        var som = dayjs().year(year).month(req_month).startOf('month').toDate()
        var eom = dayjs().year(year).month(req_month).endOf('month').toDate()
        return Record.aggregate(
            [
                {
                    $match: {
                        'user_uid': user_uid,
                        'date': { $gte: som, $lt: eom }
                    }
                }
            ]
        )
    }
}

//get image here only (prev one no images)
//req.id sent in flutter's request from record services 
export async function getRecord(req, res) {
    try {
        const { id } = req.params
        var records_data = await Record.findOne({ user_uid: req.uid, _id: new ObjectId(id) })
        if (records_data.length == 0) {
            res.status().json({ message: 'Record does not exist or you do not have the permission to access it.' })
        }
        // if (records_data.photo) {
        //     console.log(records_data.photo)
        // } else {
        //     console.log("NO PHOTO")
        // }
        // const obj = records_data.toObject();
        //TODO: JUST PASS NETWORK URL HERE. NO NEED FOR DECODING BASE64
        // const base64_photo = obj.photo ? obj.photo.toString('base64') : null;
        // records_data = {
        //     ...obj,
        //     photo: base64_photo
        // }
        return res.status(200).json(records_data)
    } catch (error) {
        console.error("getRecord error: ", error)
        return res.status(500).json({ message: "Server error" })
    }
}

export async function updateRecord(req, res) {
    try {
        const { id } = req.params
        var { itemName, date, cost, category, isFavourited, details, isVisible } = req.body
        const record = await Record.findOne({ user_uid: req.uid, _id: new ObjectId(id) })
        if (record.length == 0) {
            res.status().json({ message: 'Record does not exist or you do not have the permission to access it.' })
        }
        var photo_url;
        if (req.file != null) {
            const { path } = req.file
            const photo = await cloudinary.uploader.upload(req.file.path, {folder: 'uploads'})
            photo_url = photo.secure_url
            fs.unlinkSync(path)
        }

        //check if exists then assign 
        if (itemName) record.itemName = itemName
        if (date) record.date = date
        if (cost) record.cost = cost
        if (photo_url) record.photo = photo_url
        if (category) record.category = category
        if (isFavourited != null) record.isFavourited = isFavourited
        if (details) record.details = details
        if (isVisible != null) record.isVisible = isVisible

        //must save to the db 
        await record.save()
        return res.status(201).json({ message: "Successfully updated record" })
    } catch (error) {
        console.error("updateRecord error: ", error)
        return res.status(500).json({ message: "Server error" })
    }
}

export async function deleteRecord(req, res) {
    try {
        const { id } = req.params
        //check if exists first -> shd not return success if it doenst even exist 
        var record = await Record.findOne({ user_uid: req.uid, _id: new ObjectId(id) })
        if (record != null) {
            //TODO: DELETE THE IMAGE FROM CLOUDINARY IF THERE IS AN IMAGE. CHANGE COUNTDOCUMENT TO FINDONE INSTEAD 
            if (record.photo != null) {
                const cloudinary_id = extractPublicId(record.photo)
                await cloudinary.uploader.destroy(cloudinary_id)
            }
            await Record.findOneAndDelete({ user_uid: req.uid, _id: id })
        } else {
            throw new Error('Document does not exist')
        }
        return res.status(201).json({ message: "Successfully deleted record" })
    } catch (error) {
        console.error("deleteRecord error: ", error)
        return res.status(500).json({ message: "Server error" })
    }
}

export async function getItemName(req, res) {
    var delay = 2000;
    for (let i = 1; i <= 5; i++) {
        try {
            if (i > 1) {
                delay = delay * 2
            }
            const { base64_photo } = req.body;
            const imgType = checkMimeType(base64_photo)
            const GEMINI_API_KEY = process.env.GEMINI_API_KEY
            const ai = new GoogleGenAI({ apiKey: GEMINI_API_KEY });
            const response = await ai.models.generateContent({
                model: "gemini-3-flash-preview",
                contents: [{
                    inlineData: {
                        mimeType: imgType,
                        data: base64_photo
                    }
                },
                    'Identify the item in the picture and return me only the item name to be as specific as you can.' +
                    'If you are unable to map the item to a specific brand, return only the name of the food item. ' + 
                    'You are strictly not allowed to return me any other description other than the name of the food item.' +  
                    'IF YOU ARE NOT 100% SURE OF THE BRAND, DO NOT STATE IT IN YOUR RESPONSE.' +
                    'If it is not a food item, return the exact phrase "No food detected"']
            });
            return res.status(200).json({
                itemName: response.text
            })
        } catch (error) {
            console.error("getItemName error: ", error)
            if (error instanceof ApiError) {
                await new Promise(res => setTimeout(res, delay))
            } else {
                return res.status(500).json({ message: "Server error" })
            }
        }
    }
    return res.status(500).json({message: "server error. failed to receive item name"})
}

function checkMimeType(base64) {
    const signatures = {
        iVBORw0KGgo: 'image/png',
        '/9j/': 'image/jpeg',
        iVBO: 'image/jpeg',
        UklGR: 'image/webp'
    }

    // const first10Chara = base64.substring(0,10)
    for (const sign of Object.keys(signatures)) {
        if (base64.startsWith(sign)) {
            return signatures[sign];
        }
    }
    throw new Error('Invalid image format')
}