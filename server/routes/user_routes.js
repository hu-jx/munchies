import { verifyToken } from '../middleware/auth_middleware.js'
import express from 'express'
import upload from '../middleware/multer.js'
import {searchUser} from "../controllers/user_controller.js"

const userRouter = express.Router();

userRouter.use(verifyToken); 

userRouter.get('/search', searchUser);

export default userRouter