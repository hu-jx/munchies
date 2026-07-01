import mongoose from "mongoose"
import { Goal } from "../models/goal.js"
import dayjs from 'dayjs'
import 'dayjs/locale/en-sg.js'
dayjs.locale('en-sg')

const ObjectId = mongoose.Types.ObjectId
const EPOCH = dayjs('2020-01-06')
const absoluteWeek = (date) => dayjs(date).diff(EPOCH, 'week')

//GET goal 
export async function getLatestGoal(req, res) {
    try {
        const goals_data = await Goal.find({ user_uid: req.uid, isActive: true }).sort('-start_week').limit(1)
        if (!goals_data || goals_data.length == 0) {
            return res.status(204).json({ message: "No data found" })
        }
        return res.status(200).json(goals_data)
    } catch (error) {
        console.error("getLatestGoal error: ", error)
        return res.status(500).json({ message: "Server error" })
    }
}

//POST goal - create a totally new one
export async function createNewGoal(req, res) {
    try {
        const { quantity, start_date } = req.body;
        if (parseInt(quantity) < 0) {
            throw Error('Invalid goal quantity value')
        }
        var newGoal = Goal({
            user_uid: req.uid,
            quantity: quantity,
            start_week: absoluteWeek(start_date),
            isActive: true,
            start_date: start_date
        });
        await newGoal.save()
        return res.status(201).json({ message: "Successfully created new goal" })
    } catch (error) {
        console.error("createNewGoal error: ", error)
        return res.status(500).json({ message: "Server error" })
    }
}

//PATCH goal - update existing list of goals
export async function updateGoalById(req, res) {
    try {
        console.log("REACHED GOAL CONTROLLER")
        const { id } = req.params;
        const { quantity, isActive, start_date } = req.body;
        var current = await Goal.findOne({ _id: new ObjectId(id) })
        //update values
        if (current == null) {
            throw Error('No goal found')
        } else {
            if (quantity != null) current.quantity = quantity
            if (isActive != null) current.isActive = isActive
            if (start_date) {
                current.start_week = absoluteWeek(start_date)
                current.start_date = start_date
            } 
            await current.save()
        }
        return res.status(201).json(current)
    } catch (error) {
        console.error("updateGoalById error: ", error)
        return res.status(500).json({ message: "Server error" })
    }
}

//DELETE goal
export async function deleteGoalById(req, res) {
    try {
        const { id } = req.params;
        //check if exist first
        var goal = await Goal.findOne({ _id: new ObjectId(id) })
        if (goal == null) {
            throw Error('No goal with the given id found')
        }
        await Goal.findOneAndDelete(
            { _id: new ObjectId(id) }
        )
        return res.status(201).json({ message: "Successfully deleted goal" })
    } catch (error) {
        console.log("deleteGoal error: ", error)
        return res.status(500).json({ message: "Server error" })
    }
}

export async function deleteGoalHistory(req, res) {
    //clear inactive goals
    try {
        await Goal.deleteMany(
            { user_uid: req.uid, isActive: false }
        )
        return res.status(201).json({ message: "Successfully deleted goal" })
    } catch (error) {
        console.log("deleteGoal error: ", error)
        return res.status(500).json({ message: "Server error" })
    }
}

//upload all current goals to be inactive when starting a new, higher goal 
export async function updateCurrentGoalsToInactive(req, res) {
    try {
        var { activeStatus } = req.query
        const filter = { user_uid: req.uid }
        const update = { isActive: activeStatus }
        await Goal.updateMany(filter, update)
        return res.status(201).json({ message: "Successfully updated all goals status" })
    } catch (error) {
        console.error("updateGoalStatus error: ", error)
        return res.status(500).json({ message: "Server error" })
    }
}
