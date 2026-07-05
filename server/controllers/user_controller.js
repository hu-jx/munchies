// search for other users using email

import { User } from "../models/user.js"

//this finds user info using their mongo unique id in the database
export async function findUserInfo(req, res) {
    try {
        var { mongo_id } = req.query
        const user_profile = await User.findOne({
            _id: mongo_id
        })
        if (!user_profile) {
            return res.status(204).json({ message: "No user found" })
        }
        return res.status(200).json(user_profile)
    } catch (error) {
        console.error("findUserInfo error: ", error)
        return res.status(500).json({ message: "Server error" })
    }
}    

export async function searchUser(req, res) {
    try {
        var { search_email, user_uid } = req.query
        const search_profile = await User.findOne({
            emailAddress: {
                //$regex: `^${search_email}$`, $options: "i"
                $regex: new RegExp("^" + search_email + "$", "i")
            }
        })
        if (!search_profile) {
            return res.status(204).json({ message: "No user found" })
        }
        return res.status(200).json(search_profile)
    } catch (error) {
        console.error("searchUser error: ", error)
        return res.status(500).json({ message: "Server error" })
    }
}

// get find_friends
export async function findFriends(req, res) {
    try {
        const user_json = await User.findOne(
            {
                firebase_uid: req.uid,
            }).populate('friends')
        if (!user_json) {
            return res.status(404).json({ message: "No user found" })
        }
        return res.status(200).json(user_json.friends)
    } catch (error) {
        console.error("findFriends error: ", error)
        return res.status(500).json({ message: "Server error" })
    }
}

//http://localhost:3000/api/search?search_email=email...y&user_uid=BqCmKTsSE3dNmEzpJ6No9zCD3ZN2 