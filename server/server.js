//Importing lib and environment variables
import dotenv, { config } from 'dotenv'
config({quiet: true})
import express, { json } from 'express'
import {connectDB} from './config/db.js'
import authRouter from './routes/auth_routes.js'
import recordRouter from './routes/record_routes.js'

const app = express()
const PORT = process.env.PORT || 3000

//Configuration
app.use(json())
app.use('/api', authRouter)
app.use('/api', recordRouter)

const startServer = async () => {
    await connectDB()
    app.listen(PORT, () => console.log('Server runnning on', PORT))
}

startServer()