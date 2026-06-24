//using rolling averages 

export function predictions(dataValues, windowSize) {

    const values = [...dataValues];
    const predictedValues = [];

    for (let i = 0; i < 6; i++) {
        const window = values.slice(-windowSize);
        var sum = 0;
        for (let j = 0; j < window.length; j++) {
            sum += window[j]
        }
        const avg = sum / window.length;
        predictedValues.push(avg);
        values.push(avg)
    }

    return predictedValues;
}