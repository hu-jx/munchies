import dayjs from "dayjs"
import { Goal } from "../models/goal.js"
import { Record } from "../models/record.js"
import { computeStreak } from "../utils/streak_calculator.js"
import 'dayjs/locale/en-sg.js'
import DataError from "../utils/errors/insufficient_data_error.js"
dayjs.locale('en-sg')

export async function getCurrentStreak(req, res) {
    try {
        const active_goals = await Goal.find({ user_uid: req.uid, isActive: true }).sort('start_week')
        if (active_goals == null || active_goals.length == 0) {
            return res.status(204).json({ message: "No active goals found" })
        }
        const oldest_goal_date = dayjs(active_goals[0].start_date).startOf('week').toDate()
        const record_count_by_week = await Record.aggregate(
            [
                {
                    $match: {
                        user_uid: req.uid,
                        date: {
                            $gte: oldest_goal_date,
                        }
                    }
                },
                {
                    $group: {
                        _id: {
                            $dateTrunc: {
                                date: "$date",
                                unit: "week",
                                startOfWeek: "monday",
                                timezone: "Asia/Singapore"
                            }
                        }
                        ,
                        count: {
                            $sum: 1
                        }
                    }
                },
                {
                    $sort: { _id: -1 }
                }
            ]
        )
        console.log(record_count_by_week)
        if (record_count_by_week == undefined || record_count_by_week == null) {
            record_count_by_week = []
        }
        var streak = computeStreak(active_goals, record_count_by_week, oldest_goal_date)
        return res.status(200).json({ "streak": streak })
    } catch (error) {
        if (error instanceof DataError) {
            return res.status(204).json({message: "Not enough data"})
        }
        console.error(error)
        return res.status(500).json({ message: "Server error" })
    }
}