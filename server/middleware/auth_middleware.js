import { getAuth } from '../config/firebase.js'

//Obtain the token from request
export async function verifyToken(req, resp, next) {
    try {
        var token = req.headers.authorization?.split(" ")[1]
        //check token
        var decoded_token = await getAuth().verifyIdToken(token)
        //if verified & no error 
        resp.uid = decoded_token.uid
        next()
    } catch (error) {
        resp.status(401).json({ message: 'Invalid Token' })
    }
}