import { predictions } from '../utils/prediction_model.js'
import { Record } from "../models/record.js"


export async function predictData(user_uid) {
    //check if the total number of months > 3, if not return error message
    //check per category

    const minLength = 3;

    //data aggregation
    const allTimeData = await Record.aggregate([
        {
            $match: {
                user_uid: user_uid,
            }
        },
        {
            $group: {
                //group by day/week/month, totalCost and Num for that period
                _id: { $dateTrunc: { date: "$date", unit: "month" } },
                totalCost: { $sum: '$cost' },
                totalNum: { $sum: 1 }

            },
        },
        {
            $sort: { _id: -1 }
        }
    ])

    const allCatData = await Record.aggregate([
        {
            //group by category, then by month...? the totalCatCost and totalCatNum
            $match: {
                user_uid: user_uid,
            }
        },
        {
            $group: {
                _id: { category: '$category', month: { $dateTrunc: { date: "$date", unit: "month" } } },
                costPerCat: { $sum: '$cost' },
                numPerCat: { $sum: 1 }
            }
        }
    ])

    //predicting summary data 
    const totalCosts = allTimeData.map(entry => entry.totalCost);
    const totalCounts = allTimeData.map(entry => entry.totalNum);

    let summaryPrediction = null;
    if (totalCosts.length >= minLength) {
        summaryPrediction = {
            predictedCosts: predictions(totalCosts, 6),
            predictedCounts: predictions(totalCounts, 6),
        };
    }

    //labelled predicted month FIRST, change if using summaryData
    const summaryArray = summaryPrediction
        ? summaryPrediction.predictedCosts.map((cost, index) => ({
            _id: `predicted-month-${index + 1}`,
            totalCost: cost,
            totalNum: summaryPrediction.predictedCounts[index]
        }))
        : [];


    //prep the data to be put into the prediction model
    const groupedCatData = {};
    for (const entry of allCatData) {
        const category = entry._id.category;
        if (!(category in groupedCatData)) {
            groupedCatData[category] = { costs: [], counts: [] }
        }
        groupedCatData[category].costs.push(entry.costPerCat);
        groupedCatData[category].counts.push(entry.numPerCat)
    }

    //predict category data
    const catPredictions = {};
    for (const category in groupedCatData) {
        if (groupedCatData[category].costs.length < minLength) {
            //result[category] = { status: "insufficient_data" };
            continue;
        }
        catPredictions[category] = {
            predictedCosts: predictions(groupedCatData[category].costs, 6),
            predictedCounts: predictions(groupedCatData[category].counts, 6),
        };
    }

    const catDataArray = [];
    for (const category in catPredictions) {
        const predicted = catPredictions[category];

        const totalPredictedCost = predicted.predictedCosts.reduce((sum, v) => sum + v, 0);
        const totalPredictedNum = predicted.predictedCounts.reduce((sum, v) => sum + v, 0);

        catDataArray.push({
            _id: { category: category },
            costPerCat: totalPredictedCost,
            numPerCat: totalPredictedNum
        });
    }

    return {
        summary: summaryArray,
        catData: catDataArray,
    };

}
