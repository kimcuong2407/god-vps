// tp lần 1 được 30$ 
// TP lệnh 2 được 42$ 
const pointEarnDola = 100;

const firstTradeOrderType = 'buy';
//dynamic
const rr = 3;
const Money1RFirst = 10;
const Money1RSecond = 14;
const xxLot = 5;
// end dynamic
const pointWinSize = Money1RFirst * pointEarnDola / xxLot;
const pointLoseSize = Money1RSecond * pointEarnDola / xxLot;
const lotSize = 0.01 * xxLot;
let volume = 1;
const orderTypeAndMoneyRR = [{
    'type': firstTradeOrderType,
    'moneyRR': Money1RFirst,
}, {
    'type': firstTradeOrderType == 'buy' ? 'sell' : 'buy',
    'moneyRR': Money1RSecond,
}];

// input1 : nhập vào số lệnh mà sẽ đạt tới TP
// logic
// vào lệnh Hedge nếu lệnh trước đó SL thì vào lệnh ngược chiều với lệnh trước đó với tỉ lệ RR: 1:3
// output: số tiền lãi

function totalRRWinAndLose(max) {
    let currentMoneyRR = orderTypeAndMoneyRR.find(item => item.type == firstTradeOrderType).moneyRR;
    const results = [{
        type: firstTradeOrderType,
        sl: currentMoneyRR * volume,
        tp: currentMoneyRR * volume * rr,
        tradeNumber: 1,
        volume: volume,
        lot: volume * lotSize,
    }];
    console.log(`Win trade so ${1}: `, calculateProfit(results));

    for (let i = 2; i <= max; i++) {
        const orderType = results[i - 2].type == 'buy' ? 'sell' : 'buy';
        let currentMoneyRR = orderTypeAndMoneyRR.find(item => item.type == orderType).moneyRR;
        let currentVolume = 1;
        results.push({
            type: orderType,
            sl: currentMoneyRR * currentVolume,
            tp: currentMoneyRR * currentVolume * rr,
            tradeNumber: i,
            volume: currentVolume,
            lot: currentVolume * lotSize,
        });
        while (calculateProfit(results) < 5) {
            currentVolume++;
            results.pop()
            results.push({
                type: orderType,
                sl: currentMoneyRR * currentVolume,
                tp: currentMoneyRR * currentVolume * rr,
                tradeNumber: i,
                volume: currentVolume,
                lot: currentVolume * lotSize,
            });
        }
        console.log(`Win trade so ${i}: `, calculateProfit(results));
    }
    console.log('volumes: ', results.map(i => i.volume).join('|'));
    console.log(results.map(i => ({
        sl: i.sl,
        tp: i.tp,
        lot: i.lot,
    })));
    
    return calculateProfit(results);
}

function calculateProfit(results) {
    const typeProfit = results[results.length - 1].type;
    return results.reduce((acc, item) => {
        if (item.type == typeProfit) {
            acc += item.tp;
        } else {
            acc -= item.sl + item.tp;
        }
        return acc;
    }, 0)
}
totalRRWinAndLose(15);

console.log('pointWinSize', pointWinSize, 'pointLoseSize', pointLoseSize, 'lotSize', lotSize);
