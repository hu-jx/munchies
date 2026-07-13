import { verifyToken } from '../middleware/auth_middleware.js'
import express from 'express'
import upload from '../middleware/multer.js'
import { addFCMToken, findFriends, findUserInfo, getNotifCount, removeFriend, searchUser } from "../controllers/user_controller.js"

const userRouter = express.Router();

userRouter.use(verifyToken); 

userRouter.get('/search', searchUser);
userRouter.get('/find_friends', findFriends)
userRouter.get('/find_user_info', findUserInfo)
userRouter.post('/add_token', addFCMToken)
userRouter.get('/get_notif_count', getNotifCount)
userRouter.delete('/remove_friend', removeFriend)

export default userRouter