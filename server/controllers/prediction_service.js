import { predictions } from '../utils/prediction_model.js'
import { Record } from "../models/record.js"


export async function predictData(user_uid) {

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
            $match: {
                user_uid: user_uid,
            }
        },
        {
            $group: {
                //group by category, then by month 
                _id: { category: '$category', month: { $dateTrunc: { date: "$date", unit: "month" } } },
                costPerCat: { $sum: '$cost' },
                numPerCat: { $sum: 1 }
            }
        }
    ])

    //predicting summary data 
    const totalCosts = allTimeData.map(entry => entry.totalCost);
    const totalNum = allTimeData.map(entry => entry.totalNum);

    let summaryPrediction = null;
    if (totalCosts.length >= minLength) {
        summaryPrediction = {
            predictedCosts: predictions(totalCosts, 6),
            predictedNum: predictions(totalNum, 6),
        };
    }

    //labelled predicted month FIRST, change if using summaryData
    const summaryArray = summaryPrediction
        ? summaryPrediction.predictedCosts.map((cost, index) => ({
            _id: `predicted-month-${index + 1}`,
            totalCost: cost,
            totalNum: summaryPrediction.predictedNum[index]
        }))
        : [];


    //prep the data to be put into the prediction model
    const groupedCatData = {};
    for (const entry of allCatData) {
        const category = entry._id.category;
        if (!(category in groupedCatData)) {
            groupedCatData[category] = { costs: [], num: [] }
        }
        groupedCatData[category].costs.push(entry.costPerCat);
        groupedCatData[category].num.push(entry.numPerCat)
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
            predictedNum: predictions(groupedCatData[category].num, 6),
        };
    }

    const catDataArray = [];
    for (const category in catPredictions) {
        const predicted = catPredictions[category];

        const totalPredictedCost = predicted.predictedCosts.reduce((x, y) => x + y, 0);
        const totalPredictedNum = predicted.predictedNum.reduce((x, y) => x + y, 0);

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
