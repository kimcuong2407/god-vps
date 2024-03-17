const buy = 10;
const sell = 7;
const rr = 2;
const volume = 1;

// input1 : nhập vào số lệnh mà sẽ đạt tới TP
// logic
// vào lệnh Hedge nếu lệnh trước đó SL thì vào lệnh ngược chiều với lệnh trước đó với tỉ lệ RR: 1:3
// output: số tiền lãi

function totalRRWinAndLose(max = 10) {
    let buySell = 'buy';
    const results = [{
        type: buySell,
        sl: buy * volume,
        profit: buy * volume * rr,
        tradeNumber: 1,
        volume: volume,
    }];
    console.log('Win trade so 1: ', results[0].profit);
    for (let i = 2; i <= max; i++) {
        buySell = buySell == 'buy' ? 'sell' : 'buy';
        let currentVolume = results[results.length - 1].volume;
        results.push({
            type: buySell,
            sl: buySell == 'buy' ? buy * currentVolume : sell * currentVolume,
            profit: buySell == 'buy' ? buy * currentVolume * rr : sell * currentVolume * rr,
            tradeNumber: i,
            volume: currentVolume,
        });
        while (calculateProfit(results) < 0) {
            results.pop()
            currentVolume++;
            results.push({
                type: buySell,
                sl: buySell == 'buy' ? buy * currentVolume : sell * currentVolume,
                profit: buySell == 'buy' ? buy * currentVolume * rr : sell * currentVolume * rr,
                tradeNumber: i,
                volume: currentVolume,
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