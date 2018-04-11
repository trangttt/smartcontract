var constants = require('../config/ShareTokenFigures.js');
/*
 * Get balance of an account
 */
var getBalance = async function(token, account){
    const balance = await token.balanceOf(account);
    return balance.toNumber();
}

/*
 * Sell to an *account* a *number* of token, and return the current balance
 */
 var sellToAccount = async function(token, mainsale, account, number){
    // 10^18 wei = ETH_USD_RATE cent
    // 1 token = TOKEN_PRICE cent
    // exclude decimal places, as TOKEN_PRICE doesn't include decimal places

    number = number / 10**constants.DECIMAL_PLACES;


    var value = number * ( constants.TOKEN_PRICE * (10**18) / constants.ETH_USD_RATE);

    const tx = await mainsale.sendTransaction({from: account, value: value});

    return getBalance(token, account);
}


/*
 * Stringify *Transfer* event
 */
var transferString = function(event){
    const args = event.args
    return ["Transfer(From: " + args._from,
            "To: " + args._to,
            "Value: " + args._value.toNumber() + ")"].join(", ")
}


/*
 * Stringify *Approval* event
 */
var approvalString = function(event){
    const args = event.args
    return ["{Owner: " + args._from,
            "Spender: " + args._to,
            "Value: " + args._value.toNumber()].join(", ")
}


module.exports = {
    getBalance,
    sellToAccount,
    transferString,
    approvalString
}
