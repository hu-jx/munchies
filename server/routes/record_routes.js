import { verifyToken } from '../middleware/auth_middleware.js'
import express from 'express'
import { createRecord, getAllRecords, getRecord, updateRecord, deleteRecord} from '../controllers/record_controller.js';
const recordRouter = express.Router()

recordRouter.use(verifyToken);  // verify token before any other routes here can be used

recordRouter.post('/records', createRecord);
// recordRouter.get('/scan', createRecordWithScan);
recordRouter.get('/records', getAllRecords);
recordRouter.get('/records/:id', getRecord);
recordRouter.patch('/records/:id', updateRecord);
recordRouter.delete('/records/:id', deleteRecord);

export default recordRouter