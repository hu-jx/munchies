import {mongoose} from 'mongoose'
import { config } from 'dotenv'
config({quiet: true})

const url = process.env.MONGO_URL
const connection = mongoose.connection
mongoose.set('strictQuery', true)

export const connectDB = async () => {
    //Connection event listeners // 
    connection.on('connected', () => console.log("Connected to MongoDB"))
    connection.on('reconnected', () => console.log("Reconnected to MongoDB"))
    connection.on('disconnected', () => {
        console.log("Disconnected from MongoDB. Retrying in 5 seconds...")
        setTimeout(() => {
            mongoose.connect(url)
        }, 5000)
    })
    connection.on('close', () => console.log('Close connection'))
    connection.on('error', (error) => console.log('Error occurred: ', error.message))

    //If connected, do nothing. Else, start initial connection to database
    if (connection.readyState == 1 || connection.readyState == 2) {
        console.log("Already connected or in process of connecting...")
        return
    } else {
        //Start initial connection 
        await mongoose.connect(url)
            .then(() => console.log("Successfully connected"))
            .catch(err => {
                console.log('Error occurred: ', err.message)
                process.exit(1)
            })
    }
}
