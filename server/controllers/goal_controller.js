import mongoose from "mongoose"
import { Goal } from "../models/goal.js"
import dayjs from 'dayjs'
import 'dayjs/locale/en-sg.js'
import { calculateGoal } from "../utils/adaptive_goal_calc.js"
import DataError from "../utils/errors/insufficient_data_error.js"
import { Record } from "../models/record.js"
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

export async function getPureAdaptiveGoal(req, res) {
    try {
        var four_week_ago = dayjs().subtract(4, 'week').startOf('week').toDate()
        var start_of_week = dayjs().startOf('week').toDate()
        console.log(four_week_ago, start_of_week)
        var four_week_record_count = await Record.aggregate(
                    [
                        {
                            $match: {
                                user_uid: req.uid,
                                date: {
                                    $gte: four_week_ago, 
                                    $lte: start_of_week
                                }
                            }
                        },
                        {
                            $group: {
                                _id: {
                                    $dateTrunc: {
                                        date: "$date",
                                        unit: "week",
                                        startOfWeek: "monday"
                                    }
                                }
                                ,
                                count: {
                                    $sum: 1
                                }
                            }
                        },
                        {
                            $sort: { _id: 1 }
                        }
                    ]
                )
        if (four_week_record_count == undefined || four_week_record_count == null || four_week_record_count.length == 0 ) {
            throw new DataError('Not enough data')
        }
        var recc_goal = calculateGoal(four_week_record_count)
        if (recc_goal == undefined || recc_goal == null ) {
            console.log('no goal found, hence return the default goal')
            recc_goal = 2
        }
        return res.status(200).json({'goal': recc_goal})
    } catch (error) {
        if (error instanceof DataError) {
            return res.status(422).json({message: "Not enough data to create an adaptive goal"})
        }
        console.error("getAdaptiveGoal error in controller", error);
        return res.status(500).json({message: "server error"})
    }
}
