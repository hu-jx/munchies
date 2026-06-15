import { verifyToken } from '../middleware/auth_middleware.js'
import express from 'express'
import { createRecord, getAllRecords, getRecord, updateRecord, deleteRecord, getItemName} from '../controllers/record_controller.js';
import upload from '../middleware/multer.js'
const recordRouter = express.Router()

recordRouter.use(verifyToken);  // verify token before any other routes here can be used

recordRouter.post('/records', upload.single('photo'), createRecord);
recordRouter.post('/name', getItemName);
recordRouter.get('/records', getAllRecords);
recordRouter.get('/records/:id', getRecord);
recordRouter.patch('/records/:id', upload.single('photo'), updateRecord);
recordRouter.delete('/records/:id', deleteRecord);

export default recordRouter