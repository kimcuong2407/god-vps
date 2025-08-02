const DolaEarnEachOneLot = 100; // số tiền kiếm đc với 1 lot và 100 point
const pointEarnEachDola = DolaEarnEachOneLot / 100; // số tiền kiếm đc với 100point và lot = 0.01

const firstTradeOrderType = 'buy';
//dynamic
const rr = 1.5;
const Money1RFirst = 3;
const points = 300;
let MoneyWinMinEachTrade = 15;
// end dynamic
const fixedNumber = 2;
const lotFirstTrade = ((Money1RFirst / points) / pointEarnEachDola).toFixed(fixedNumber);

const money1RExpected = () => {
    return points * pointEarnEachDola / 100;
}

console.log('Money1RFirst % money1RExpected', Money1RFirst % money1RExpected())
console.log('Money1R Expected', money1RExpected())
console.log('lotFirstTrade', lotFirstTrade);
let volume = 1;
const orderTypeAndMoneyRR = [{
    'type': firstTradeOrderType,
    'lotSize': lotFirstTrade,
}, {
    'type': firstTradeOrderType == 'buy' ? 'sell' : 'buy',
    'lotSize': lotFirstTrade,
}];

// input1 : nhập vào số lệnh mà sẽ đạt tới TP
// logic
// vào lệnh Hedge nếu lệnh trước đó SL thì vào lệnh ngược chiều với lệnh trước đó với tỉ lệ RR: 1:3
// output: số tiền lãi

function totalRRWinAndLose(max) {
    if (Money1RFirst % money1RExpected() != 0) {
        console.log('Money1RFirst is not correct');
        return;
    }
    let totalLot = 0;
    let moneyWin = Money1RFirst;
    const results = [{
        type: firstTradeOrderType,
        sl: Money1RFirst,
        tp: Money1RFirst * rr,
        tradeNumber: 1,
        lot: lotFirstTrade,
    }];
    console.log('moneyWin', moneyWin);
    totalLot += parseFloat(lotFirstTrade);
    console.log(`Win trade so 1: ${calculateProfit(results)} and current lot: ${lotFirstTrade} --- totalLot: ${totalLot}`);

    for (let i = 2; i <= max; i++) {
        const lastResult = results[i - 2];
        let currentLotSize = lotFirstTrade;
        const orderType = lastResult.type == 'buy' ? 'sell' : 'buy';
        results.push({
            type: orderType,
            sl: Math.round(currentLotSize * points),
            tp: Math.round(currentLotSize * points) * rr,
            tradeNumber: i,
            lot: currentLotSize,
        });

        moneyWin = moneyWin + MoneyWinMinEachTrade + totalLot * 7;
        console.log('moneyWin', moneyWin);
        while (calculateProfit(results) < moneyWin) {
            currentLotSize = (parseFloat(currentLotSize) + 0.01).toFixed(fixedNumber);
            results.pop()
            results.push({
                type: orderType,
                sl: Math.round(currentLotSize * points),
                tp: Math.round(currentLotSize * points) * rr,
                tradeNumber: i,
                lot: currentLotSize,
            });
        }

        totalLot += parseFloat(currentLotSize);
        console.log(`Win trade so ${i}: ${calculateProfit(results)} and current lot: ${currentLotSize} --- totalLot: ${totalLot}`);
    }

    const lotSize = results.map(i => i.lot).join('|');
    console.log('lotSize', lotSize);

    return calculateProfit(results);
}
totalRRWinAndLose(15);

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

// console.log('moneyFirstTp', Money1RFirst, 'lotSizeFirst', lotFirstTrade,);
