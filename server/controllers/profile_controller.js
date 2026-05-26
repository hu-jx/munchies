//get the profile that matches the firebase_uid (a foreign key for the two databases)

import { User } from "../models/user.js"

export async function getProfile (req, res) {
    const profile_data = await User.findOne({firebase_uid: req.firebase_uid})
    res.status(200).json(profile_data)
}

export async function createProfile (req, res) {
    const {username, firstName, emailAddress, lastName } = req.body
    const new_profile = new User({
        firebase_uid: req.uid,
        username,
        firstName,
        emailAddress,
        lastName
})
    await new_profile.save()
    res.status(201).json({message: "Successfully created new profile"})
}
