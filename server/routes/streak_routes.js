import { getCurrentStreak } from '../controllers/streak_controller.js';
import { verifyToken } from '../middleware/auth_middleware.js'
import express from 'express'

const streakRouter = express.Router();

streakRouter.use(verifyToken); 

streakRouter.get('/streak', getCurrentStreak)
export default streakRouter