//get the profile that matches the firebase_uid (a foreign key for the two databases)

import { User } from "../models/user.js"

export async function getProfile(req, res) {
    try {
        const profile_data = await User.findOne({ firebase_uid: req.uid })
        if (!profile_data) {
            return res.status(204).json({ message: "No data found" })
        }
        return res.status(200).json(profile_data)
    } catch (error) {
        console.error("getProfile error: ", error)
        return res.status(500).json({ message: "Server error" })
    }
}

export async function createProfile(req, res) {
    try {
        const { username, firstName, emailAddress, lastName } = req.body

        //create new profile
        const new_profile = new User({
            firebase_uid: req.uid,
            username,
            firstName,
            emailAddress,
            lastName
        })
        await new_profile.save()
        return res.status(201).json({ message: "Successfully created new profile" })
    } catch (error) {
        console.error("createProfile error: ", error)
        return res.status(500).json({ message: "Server error occurred" })
    }
}
