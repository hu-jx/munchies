import { findRecommendation } from "../controllers/recommendations_controller.js";
import express from 'express'
import { verifyToken } from '../middleware/auth_middleware.js'

const recommendationRouter = express.Router()

recommendationRouter.use(verifyToken);  // verify token before any other routes here can be used


//route for getting recommendations
recommendationRouter.get('/recommendations', findRecommendation)

export default recommendationRouter