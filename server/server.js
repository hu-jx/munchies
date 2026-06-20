//Importing lib and environment variables
import dotenv, { config } from 'dotenv'
config({quiet: true})
import express, { json } from 'express'
import {connectDB} from './config/db.js'
import authRouter from './routes/auth_routes.js'
import recordRouter from './routes/record_routes.js'
import fs from 'fs';
import userRouter from './routes/user_routes.js'
import requestRouter from './routes/request_routes.js'

const app = express()
const PORT = process.env.PORT || 3000

//Configuration
if (!fs.existsSync('./uploads')) {
  fs.mkdirSync('./uploads');
}
app.use(express.json({ limit: '20mb' }));
app.use(express.urlencoded({ limit: '20mb', extended: true }));
app.use('/api', authRouter)
app.use('/api', recordRouter)
app.use('/api', userRouter)
app.use('/api', requestRouter)

const startServer = async () => {
    await connectDB()
    app.listen(PORT, () => console.log('Server runnning on', PORT))
}

startServer()