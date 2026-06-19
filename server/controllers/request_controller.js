import { Request } from "../models/request.js";
import { User } from "../models/user.js";

//http://localhost:3000/api/send_req?sender_id=&receiver_id=
//..?sender_id= & receiver_id=
// send/create a new request
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
        //else if it is already in the database
        if (in_database) {
            return res.status(400).json({ message: "Request already exists" })
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

/*
// accept request
export async function acceptRequest(req, res) { }

// decline request 
export async function declineRequest(req, res) { }
*/

//update request
//change the status to accept/decline
//sender_id=&receiver_id=&response=accepted/declined
export async function updateRequest(req, res) {
    try {
        var { sender_id, receiver_id, response } = req.query

        const existingReq = await Request.findOne({
            $or: [
                { sender_id: sender_id, receiver_id: receiver_id },
                { sender_id: receiver_id, receiver_id: sender_id }
            ]
        });

        existingReq.status = response
        await existingReq.save()

        //if is accept, update the friends list of the user
        if (response === "accepted") {
            await User.findByIdAndUpdate(
                existingReq.sender_id, 
                { $push: {friends: existingReq.receiver_id}});
            await User.findByIdAndUpdate(
                existingReq.receiver_id, 
                { $push: {friends: existingReq.sender_id}});
            
        }

        return res.status(201).json({ message: "Successfully change status" })
    } catch (error) {
        console.error("updateRequest error: ", error)
        return res.status(500).json({ message: "Server error" })
    }

}


// get pending requests
// get_pending_req?user_uid=....
export async function getPendingRequest(req, res) {
    try {
        var { user_uid } = req.query

        var pendingRequests = await Request.find({
            receiver_id: user_uid,
            status: "pending"
        });

        return res.status(200).json(pendingRequests)
    } catch (error) {
        console.error("getPendingRequest error: ", error)
        return res.status(500).json({ message: "Server error" })
    }
    var { user_uid } = req.query

    var pendingRequests = await Request.find({
        receiver_id: user_uid,
        status: "pending"
    });
}


// check status, 4 outcomes: does not exist, accepted, sent BY user, sent TO user
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
            return res.status(200).json({ message: "Requested by user" })
        } else if (existingReq.status === "pending"
            && sender_id.toString() === existingReq.receiver_id.toString()) {
            //pending and sent by the sender 
            return res.status(200).json({ message: "Requested by other user" })
        } else {
            return res.status(200).json({ message: "Declined" })
        }

    }
    return "Does not exist"

}
