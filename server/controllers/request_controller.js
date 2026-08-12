import { Request } from "../models/request.js";
import { User } from "../models/user.js";

//create a new request
export async function createRequest(req, res) {
    try {
        var { sender_id, receiver_id } = req.body

        //if sender_id, receiver_id is the same 
        if (sender_id === receiver_id) {
            return res.status(400).json({ message: "Cannot send request to yourself!" })
        }
        const in_database = await Request.findOne({
            $or: [
                { sender_id: sender_id, receiver_id: receiver_id },
                { sender_id: receiver_id, receiver_id: sender_id }
            ]
        })
        if (in_database) {
            //for accepted/pending statuses
            return res.status(400).json({ message: "Request already exists" })
            //FUTURE IMPLEMENTATION(not meant for Orbital submission): if the status is declined, revive it by updating its status to pending and senders and receivers
        }

        const new_req = new Request({
            sender_id: sender_id,
            receiver_id: receiver_id
        })
        await new_req.save()
        return res.status(201).json({ message: "Successfully sent request" })
    } catch (error) {
        console.error("createRecord error: ", error)
        return res.status(500).json({ message: "Server error occurred" })
    }
}


export async function updateRequest(req, res) {
    try {
        var { sender_id, receiver_id, response } = req.query

        const existingReq = await Request.findOne({
            $or: [
                { sender_id: sender_id, receiver_id: receiver_id },
                { sender_id: receiver_id, receiver_id: sender_id }
            ]
        });

        if (! existingReq.status ) {
            return res.status(400).json({ message: "No existing request between these 2 users" });
        }

        if (existingReq.status === "accepted") {
            return res.status(400).json({ message: "Already accepted request, cannot modify" });
        }

        const prevAccepted = (existingReq.status === "accepted")

        existingReq.status = response
        await existingReq.save()

        //if is accept, update the friends list of the user
        //addToSet and extra checks to ensure adding to list is only done once 
        if ((response === "accepted") && !prevAccepted) {
            await User.findByIdAndUpdate(
                existingReq.sender_id,
                { $addToSet: { friends: existingReq.receiver_id } });
            await User.findByIdAndUpdate(
                existingReq.receiver_id,
                { $addToSet: { friends: existingReq.sender_id } });

        }

        return res.status(201).json({ message: "Successfully changed status" })
    } catch (error) {
        console.error("updateRequest error: ", error)
        return res.status(500).json({ message: "Server error" })
    }

}


export async function getPendingRequest(req, res) {
    try {
        //var { user_uid } = req.query
        const user_json = await User.findOne(
            {
                firebase_uid: req.uid,
            }).populate('friends')
        if (!user_json) {
            return res.status(404).json({ message: "No user found" })
        }

        var pendingRequests = await Request.find({
            receiver_id: user_json._id,
            status: "pending"
        }).populate('sender_id');

        return res.status(200).json(pendingRequests)
    } catch (error) {
        console.error("getPendingRequest error: ", error)
        return res.status(500).json({ message: "Server error" })
    }
}


// check status, 5 outcomes: does not exist, accepted, sent BY user, sent TO user
export async function checkStatus(req, res) {
    var { sender_id, receiver_id } = req.query;
    const existingReq = await Request.findOne({
        $or: [
            { sender_id: sender_id, receiver_id: receiver_id },
            { sender_id: receiver_id, receiver_id: sender_id }
        ]
    });

    if (existingReq) {
        if (existingReq.status === 'accepted') {
            return res.status(200).json({ message: "Accepted" })
        } else if (existingReq.status === "pending"
            && sender_id.toString() === existingReq.sender_id.toString()) {
            //pending and sent by the user themselves
            return res.status(200).json({ message: "From user" })
        } else if (existingReq.status === "pending"
            && sender_id.toString() === existingReq.receiver_id.toString()) {
            //pending and sent by the sender 
            return res.status(200).json({ message: "To user" })
        } else {
            return res.status(200).json({ message: "Declined" })
        }

    } else {
        return res.status(200).json({ message: "Request does not exist" })
    }

}
