/*
 * Get balance of an account
 */
var getBalance = async function(token, account){
    const balance = await token.balanceOf(account);
    return balance.toNumber()
}

/*
 * Sell to an *account* a *number* of token, and return the current balance
 */
 var sellToAccount = async function(token, account, number){
    const tx = await token.sell(account, number);

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
