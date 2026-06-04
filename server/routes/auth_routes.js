import { verifyToken } from '../middleware/auth_middleware.js'
import { getProfile, createProfile } from '../controllers/profile_controller.js'
import express from 'express'
const authRouter = express.Router()

//loading existing profile after login
authRouter.get('/profile', verifyToken, getProfile)
authRouter.post('/profile', verifyToken, createProfile)

export default authRouter