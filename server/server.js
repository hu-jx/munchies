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
import goalRouter from './routes/goal_routes.js'
import streakRouter from './routes/streak_routes.js'
import recommendationRouter from './routes/recommendations_routes.js'
import testNotifRouter from './routes/testNotifs_routes.js'
import { startScheduling } from './utils/notif_schedular.js'
import cors from 'cors';
const app = express()
app.use(cors())
const PORT = process.env.PORT || 3000

//Configuration
if (!fs.existsSync('./uploads')) {
  fs.mkdirSync('./uploads');
}
app.use(express.json({ limit: '20mb' }));
app.use(express.urlencoded({ limit: '20mb', extended: true }));
app.get('/ping', (req, res) => {
  res.status(200).send('OK')
})
app.use('/api', authRouter)
app.use('/api', recordRouter)
app.use('/api', userRouter)
app.use('/api', requestRouter)
app.use('/api', goalRouter)
app.use('/api', streakRouter)
app.use('/api', recommendationRouter)
app.use('/api', testNotifRouter)


const startServer = async () => {
    await connectDB()
    app.listen(PORT, () => console.log('Server runnning on', PORT))
}

startServer()
startScheduling()