const rbuy = 5;
const rsell = 3;
const rr = 2;
const volumn = 1;

// input1 : nhập vào số lệnh mà sẽ đạt tới TP
// logic
// vào lệnh Hedge nếu lệnh trước đó SL thì vào lệnh ngược chiều với lệnh trước đó với tỉ lệ RR: 1:3
// output: số tiền lãi

function totalRRWinAndLose(max = 10) {
    let buySell = 'buy';
    const results = [{
        type: buySell,
        sl: rbuy * volumn,
        profit: rbuy * volumn * rr,
        tradeNumber: 1,
        volumn,
    }];
    console.log('Win trade so 1: ', results[0].profit);
    for (let i = 2; i <= max; i++) {
        buySell = buySell == 'buy' ? 'sell' : 'buy';
        let currentVolumn = results[results.length - 1].volumn;
        results.push({
            type: buySell,
            sl: buySell == 'buy' ? rbuy * currentVolumn : rsell * currentVolumn,
            profit: buySell == 'buy' ? rbuy * currentVolumn * rr : rsell * currentVolumn * rr,
            tradeNumber: i,
            volumn: currentVolumn,
        });
        while (calculateProfit(results) < 0) {
            results.pop()
            currentVolumn++;
            results.push({
                type: buySell,
                sl: buySell == 'buy' ? rbuy * currentVolumn : rsell * currentVolumn,
                profit: buySell == 'buy' ? rbuy * currentVolumn * rr : rsell * currentVolumn * rr,
                tradeNumber: i,
                volumn: currentVolumn,
            });
        }
        console.log(`Win trade so ${i}: `, calculateProfit(results));
    }
    console.log(results);
    return calculateProfit(results);
}

function calculateProfit(results) {
    const typeProfit = results[results.length - 1].type;
    return results.reduce((acc, item) => {
        if (item.type == typeProfit) {
            acc += item.profit;
        } else {
            acc -= item.sl + item.profit;
        }
        return acc;
    }, 0)
}
function calculateLoss(results) {
    const typeProfit = results[results.length - 1].type;
    results.reduce((acc, item) => {
        if (item.type == typeProfit) {
            acc += item.profit;
        } else {
            acc -= item.sl + item.profit;
        }
        return acc;
    }, 0)
}
console.log(totalRRWinAndLose(20));