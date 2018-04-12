var constants = require('../config/ShareTokenFigures.js');
/*
 * Get balance of an account
 */
var getBalance = async function(token, account){
    const balance = await token.balanceOf(account);
    return balance.toNumber();
}

/*
 * Convert from token to wei
 */
var toWei = function(token){
    var value = token * ( constants.TOKEN_PRICE * (10**18) / constants.ETH_USD_RATE);
    return value;
}

/*
 * Convert from wei to token
 */ 
var toToken = function(value){
    var token = value * constants.ETH_USD_RATE / ( constants.TOKEN_PRICE * (10**18));
    return token
}

/*
 * Sell to an *account* a *number* of token, and return the current balance
 */
 var sellToAccount = async function(token, mainsale, account, number){
    // 10^18 wei = ETH_USD_RATE cent
    // 1 token = TOKEN_PRICE cent
    // exclude decimal places, as TOKEN_PRICE doesn't include decimal places

    // number = number / 10**constants.DECIMAL_PLACES;

    var value = toWei(number);
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

var getWeiBalance = async (address) => {
    var res = await web3.eth.getBalance(address)
    console.log("Get weiBalance", res.toNumber());
    return res.toNumber();
}

module.exports = {
    getBalance,
    sellToAccount,
    transferString,
    approvalString,
    toWei,
    toToken,
    getWeiBalance
}
