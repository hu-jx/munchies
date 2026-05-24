//Importing lib and environment variables
import dotenv, { config } from 'dotenv'
config({quiet: true})
import express, { json } from 'express'
import {connectDB} from './config/db.js'
import auth_routes from './routes/auth_routes.js'

//Config
const app = express()
const PORT = process.env.PORT || 5000

//Configuration
app.use(json())
app.use('/api', auth_routes)
const startServer = async () => {
    await connectDB()
    app.listen(PORT, () => console.log('Server runnning on', PORT))
}

startServer()