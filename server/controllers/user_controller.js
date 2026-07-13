// search for other users using email

import { Record } from "../models/record.js"
import { Request } from "../models/request.js"
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

export async function addFCMToken(req, res) {
    try {
        const { token } = req.body;

        await User.findOneAndUpdate(
            { firebase_uid: req.uid },
            { fcmToken: token }
        );

        return res.status(200).json({ message: "Successfully added FCM Token to User" })
    } catch (e) {
        console.error("addFCMToken error: ", e)
        return res.status(500).json({ message: "Server error" })
    }
}

export async function removeFriend(req, res) {
    try {
        var { sender_id, receiver_id } = req.body
        const existingReq = await Request.findOneAndDelete({
            $or: [
                { sender_id: sender_id, receiver_id: receiver_id },
                { sender_id: receiver_id, receiver_id: sender_id }
            ]
        });

        if (!existingReq) {
            return res.status(404).json({ message: "Friend request not found" });
        }
        //REMEMBER TO delete the request in the database 

        await User.findByIdAndUpdate(
            sender_id,
            { $pull: { friends: receiver_id } });
        await User.findByIdAndUpdate(
            receiver_id,
            { $pull: { friends: sender_id } });

        return res.status(200).json({ message: "Friend successfully removed" })
    } catch (e) {
        console.error("removeFriend error: ", e)
        return res.status(500).json({ message: "Server error" })
    }
}


export async function getNotifCount(req, res) {
    try {
        const prevWeek = new Date(Date.now() - 7 * 24 * 60 * 60 * 1000)

        const count = await Record.countDocuments({
            user_uid: req.uid,
            createdAt: { $gte: prevWeek }
        })

        const notifCount = Math.floor(count / 2)

        return res.status(200).json(notifCount)

    } catch (e) {
        console.error("getNotifCount error: ", e)
        return res.status(500).json({ message: "Server error" })
    }

}

//http://localhost:3000/api/search?search_email=email...y&user_uid=BqCmKTsSE3dNmEzpJ6No9zCD3ZN2 