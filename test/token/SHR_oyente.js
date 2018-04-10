var assertRevert = require('../helpers/assertRevert.js');
var expectEvent = require('../helpers/expectEvent.js');
var utilities = require('../helpers/utilities.js');
var constants = require('../config/ShareTokenFigures.js');

const ShareToken = artifacts.require('ShareToken');


//*****************************************************************************************
//                          UTILITIES  
//*****************************************************************************************
var getBalance = utilities.getBalance
var sellToAccount = utilities.sellToAccount

var sellAndTransfer = async function(contract, acc1, acc2, amount){
    console.log("Sell to", acc1, amount, "token");
    await sellToAccount(contract, acc1, amount)

    const newAmount = amount + 1;
    console.log("Transfer from", acc1, "to", acc2, "token");
    await contract.transfer(acc2, newAmount, {from: acc1});
}
//*****************************************************************************************
//                         TEST CASES 
//*****************************************************************************************

contract('ShareToken', function ([OWNER, NEW_OWNER, RECIPIENT, ANOTHER_ACCOUNT]) {
    console.log("OWNER: ", OWNER);
    console.log("RECIPIENT: ", RECIPIENT);
    console.log("ANOTHER ACCOUNT:", ANOTHER_ACCOUNT);

    beforeEach(async function () {
       this.token = await ShareToken.new();
    });

    it('Transfer should revert if the amount is larger than balance', async function(){
        const allowance = 1;
        await sellAndTransfer(this.token, NEW_OWNER, ANOTHER_ACCOUNT, allowance)
    })

    it('Integer overflow', async function(){
        const allowance  = 37717208912933073374861050775867160511051478474789766132129094234564326678807;

        //const balance = 95515132405035013240498949941729301185179799140209929091396633094036584928231;
        await sellAndTransfer(this.token, NEW_OWNER, ANOTHER_ACCOUNT, allowance)
    })
    
});
