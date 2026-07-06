import { verifyToken } from '../middleware/auth_middleware.js'
import express from 'express'
import { createRecord, getAllRecords, getRecord, updateRecord, deleteRecord, getItemName, getDashboardData, getFriendsPost, addLike, removeLike, getThisWeekRecordCount } from '../controllers/record_controller.js';
import upload from '../middleware/multer.js'
const recordRouter = express.Router()

recordRouter.use(verifyToken);  // verify token before any other routes here can be used

recordRouter.post('/records', upload.single('photo'), createRecord);
recordRouter.post('/name', getItemName);
recordRouter.get('/records', getAllRecords);
recordRouter.get('/records/:id', getRecord);
recordRouter.patch('/records/:id', upload.single('photo'), updateRecord);
recordRouter.delete('/records/:id', deleteRecord);
recordRouter.get('/dashboard', getDashboardData);
recordRouter.get('/friends_post', getFriendsPost);

//routes to add/delete likes
recordRouter.patch('/records/like/:id', addLike);
recordRouter.patch('/records/unlike/:id', removeLike);

//routes for this week count 
recordRouter.get('/week', getThisWeekRecordCount)

//route for getting recommendations
//recordRouter.get('/recommendations', getRecommendations)

export default recordRouter