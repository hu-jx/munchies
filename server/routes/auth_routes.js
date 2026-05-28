import { verifyToken } from '../middleware/auth_middleware.js'
import { getProfile, createProfile } from '../controllers/profile_controller.js'
import express from 'express'
const router = express.Router()

//loading existing profile after login
router.get('/profile', verifyToken, getProfile)
router.post('/profile', verifyToken, createProfile)

export default router