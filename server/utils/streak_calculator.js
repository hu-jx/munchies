import dayjs from 'dayjs'
import 'dayjs/locale/en-sg.js'
dayjs.locale('en-sg')

export function computeStreak(active_goals, record_count_by_week) {
    //date of comparison has to be a Monday
    const EPOCH = dayjs('2020-01-06')
    const absoluteWeek = (date) => dayjs(date).diff(EPOCH, 'week')

    active_goals = active_goals.filter(doc => doc.isActive).map(doc => ({
        start_week: parseInt(doc.start_week),
        quantity: parseInt(doc.quantity)
    }))

    // active_goals = isActive_goals.flatMap(v1 => 
    //     isActive_goals.slice(1, isActive_goals.length - 1).map(v2 => v1.quantity < v2.quantity ? v1 : null)
    // ).filter(doc => doc != null)

    // console.log(active_goals)
    // console.log(record_count)

    var record_count = new Map(
        record_count_by_week.map(entry => {
            console.log(`This week is ${absoluteWeek(dayjs(entry._id))} on ${dayjs(entry._id)} with ${entry.count}`)
            // console.log([, parseInt(entry.count)])
            return [absoluteWeek(dayjs(entry._id)), parseInt(entry.count)]
        })
    )

    // console.log(record_count)

    let curr_week = absoluteWeek(dayjs())
    let oldest_week = active_goals[0].start_week
    let curr_goal_qty = null
    let next_goal_index = 0
    let streak = 0
    var count_this_week

    for (let week = oldest_week; week <= curr_week; week++) {
        while (next_goal_index < active_goals.length && week >= active_goals[next_goal_index].start_week) {
            curr_goal_qty = active_goals[next_goal_index].quantity
            next_goal_index++
        }

        if (curr_goal_qty == null) continue

        count_this_week = record_count.get(week)

        if (count_this_week == undefined) {
            streak++
        } else if (count_this_week <= curr_goal_qty) {
            streak++
        } else {
            streak = 0
        }
        console.log(`On week ${week} of ${EPOCH.add(week, 'week')}, the streak is ${streak} with the count being ${count_this_week} and current goal quantity being ${curr_goal_qty}`)

    }
    return streak
}

// let active_goals = [
//     {
//         'quantity': 10,
//         'start_week': 335,
//         'isActive': false
//     },
//     {
//         'quantity': 13,
//         'start_week': 336,
//         'isActive': true
//     },
//     {
//         'quantity': 5,
//         'start_week': 338,
//         'isActive': true
//     }
// ]

// let record_count = [
//     {
//         '_id': '2026-06-01',
//         'count': 3
//     },
//     {
//         '_id': '2026-06-14',
//         'count': 25
//     },
//     {
//         '_id': '2026-06-23',
//         'count': 20
//     }
// ]

// console.log(computeStreak(active_goals, record_count))
// console.log(record_count)