// search for other users using email

import { User } from "../models/user.js"

export async function searchUser(req, res) {
    try {
        var { search_email, user_uid} = req.query
        const search_profile = await User.find({ emailAddress: {
            //$regex: `^${search_email}$`, $options: "i"
            $regex: new RegExp("^" + search_email + "$", "i")
        } })
        if (! search_profile.length) {
            return res.status(204).json({ message: "No user found" })
        }
        return res.status(200).json(search_profile)
    } catch (error) {
        console.error("getProfile error: ", error)
        return res.status(500).json({ message: "Server error" })
    }
}

//http://localhost:3000/api/search?search_email=email...y&user_uid=BqCmKTsSE3dNmEzpJ6No9zCD3ZN2 