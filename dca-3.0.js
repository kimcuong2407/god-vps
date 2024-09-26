// XAG=20 => đánh 0,01 thì 20point = 1$
// XAU=100 => đánh 0,01 thì 100point = 1$

// mặc định cứ 100 points = 1$ tất cả các cặp có giá trị 
const RateOneDollarEqualPoint = 100 / 100;

//dynamic
const firstTradeOrderType = 'sell';
const rr = 1.5;
const Money1RFirst = 5;
const points = 500;
const MoneyWinMinEachTrade = Money1RFirst * 1.2; // số tiền mà khi đóng all trade nhỏ nhất phải thắng được
// end dynamic
const fixedNumber = 2;
const lotFirstTrade = parseFloat((Money1RFirst / points / RateOneDollarEqualPoint).toFixed(fixedNumber));

let volume = 1;

// // input1 : nhập vào số lệnh mà sẽ đạt tới TP
// // logic
// // vào lệnh Hedge nếu lệnh trước đó SL thì vào lệnh ngược chiều với lệnh trước đó với tỉ lệ RR: 1:3
// // output: số tiền lãi
function totalRRWinAndLose(max) {
    let totalLot = 0;
    const results = [{
        sl: Money1RFirst,
        tp: Money1RFirst * rr,
        tradeNumber: 1,
        lot: lotFirstTrade,
    }];
    totalLot += lotFirstTrade;
    for (let i = 0; i < max; i++) {
        const tradeNumber = i + 1;
        let currentLotSize = calculateLot(results, results[i].lot);

        console.log(`\n\n\ntotal Loss trade số ${tradeNumber}: ${parseFloat(calculateLossTrade(results)).toFixed(fixedNumber)}`);
        results.push({
            sl: currentLotSize * points,
            tp: currentLotSize * points * rr,
            tradeNumber,
            lot: currentLotSize,
        });

        console.log(`Trade số ${tradeNumber} 
            win: ${parseFloat(results[i].tp).toFixed(fixedNumber)}
            lose: ${parseFloat(results[i].sl).toFixed(fixedNumber)} 
            lot: ${results[i].lot}`
        );
    }

    const lotSize = results.map(i => parseFloat(i.lot).toFixed(2)).join('|');

    console.log('lotSize', lotSize);
    // return calculateProfit(results);
}
totalRRWinAndLose(18);


function calculateLossTrade(results) {
    return parseFloat(results.reduce((acc, item) => {
        acc += item.sl;
        return acc;
    }, 0));
}

function calculateLot(results, beforeLotSize) {
    const currentLoss = calculateLossTrade(results)
    let result = beforeLotSize;

    while ((result * points) <= currentLoss) {
        result += result + 0.01;
    }
    return parseFloat(result);
}
// console.log('rr: ', rr, 'point: ', points, 'moneyFirstTp', Money1RFirst);
