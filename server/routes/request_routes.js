import { verifyToken } from '../middleware/auth_middleware.js'
import express from 'express'
import upload from '../middleware/multer.js'
import { checkStatus, createRequest, getPendingRequest, updateRequest } from '../controllers/request_controller.js';
import { updateRecord } from '../controllers/record_controller.js';

const requestRouter = express.Router();

requestRouter.use(verifyToken); 

requestRouter.post('/send_req', createRequest);
requestRouter.patch('/update_req', updateRequest);
requestRouter.get('/get_pending_req', getPendingRequest);
requestRouter.get('/check_status', checkStatus);


export default requestRouter