//using rolling averages 
import dayjs from 'dayjs'
import 'dayjs/locale/en-sg.js'
import DataError from './errors/insufficient_data_error.js'
dayjs.locale('en-sg')

const EPOCH = dayjs('2020-01-06')
const absoluteWeek = (date) => dayjs(date).diff(EPOCH, 'week')

function fillMissingValues(data) {
    //sort data 
    data = data.toSorted((a,b) => absoluteWeek(dayjs(a).toDate()) - absoluteWeek(dayjs(b).toDate()))
    console.log(data)
    //first week
    const first_week = absoluteWeek(dayjs(data[0]._id).toDate())
    const last_week = absoluteWeek(dayjs(data[data.length - 1]._id).toDate())
    console.log(`first week is ${first_week} and last week is ${last_week}`)

    //records map
    var record_data = new Map(
        data.map((doc) => {
            console.log("At MAP", doc._id, "to", [absoluteWeek(doc._id), parseInt(doc.count)])
            return [absoluteWeek(doc._id), parseInt(doc.count)]
        } ).toSorted(
            (r1,r2) => { 
                console.log(r1, r2)
                return r1[0] - r2[0]
            }
        )
    )
    console.log(record_data)

    var values = []

    for (let curr_week = first_week; curr_week <= last_week; curr_week++) {
        var curr_qty = record_data.get(curr_week)
        if (curr_qty == undefined) {
            values.push(0)
        } else {
            values.push(curr_qty)
        }
        console.log(`on ${curr_week}, where first is ${first_week} and last is ${last_week}, curr qty is ${curr_qty}`)
    }
    return values
}

function rolling_week_average(dataset) {
    /*expected dataset appearance: [
     {
        date: ...,
        count: ...
     }
    ]   */
   //check that every week is present and fill missing dates with 0 
   var data = fillMissingValues(dataset)
   if (data.length < 4) {
        throw new DataError('Too little data to project next week')
    }
    var weighted_sum = 0;
    const window = data.slice(-4);
    console.log(`window is ${window}`)

   for (let i = 0; i < (data.length - 4 + 1) ; i++) {
        for (let j = 0; j < window.length; j++) {
            weighted_sum += window[j] * (j + 1)
        }
    }

    const wma = Math.round(weighted_sum / (1+2+3+4))
    console.log(`the wma is ${wma}`)
    return wma;
}

export function calculateGoal(data) {
    //add bonus reduction on frontend-side -> has knowledge of streak
    var predicted_count = rolling_week_average(data)
    if (predicted_count < 0) {
        return 0
    } else if (predicted_count <= 2 && predicted_count >= 0) {
        return predicted_count
    } else if (predicted_count > 2 && predicted_count <= 7) {
        //20% reduction => assume if user uses and maintains goal
        return Math.floor(predicted_count * (1 - 0.20))
    } else {
        //high -> reach approx 75% of consumption by end of 4 weeks or one month
        return Math.floor(predicted_count / 4 * 3) 
    }
}


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
//     },
//     {
//         '_id': '2026-06-29',
//         'count': 20
//     }
// ]

// console.log(calculateGoal(record_count))
