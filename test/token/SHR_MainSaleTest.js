var assertRevert = require('../helpers/assertRevert.js');
var expectEvent = require('../helpers/expectEvent.js');
var utilities = require('../helpers/utilities.js');
var constants = require('../config/ShareTokenFigures.js');

const ShareToken = artifacts.require('ShareToken');
const MainSale = artifacts.require('MainSale');


//*****************************************************************************************
//                          UTILITIES  
//*****************************************************************************************
var getBalance = utilities.getBalance
var sellToAccount = utilities.sellToAccount
var transferString = utilities.transferString
var approvalString = utilities.approvalString
var toWei = utilities.toWei
var getWeiBalance = utilities.getWeiBalance

var expectTxEvent = expectEvent.inTransaction
var expectLogEvent = expectEvent.inLog

var assertRevert = assertRevert.assertRevert

//*****************************************************************************************
//                         TEST CASES 
//*****************************************************************************************

contract('ShareToken', function ([OWNER, NEW_OWNER, RECIPIENT, ANOTHER_ACCOUNT]) {
    var accounts = [OWNER, NEW_OWNER, RECIPIENT, ANOTHER_ACCOUNT];
    console.log("OWNER: ", OWNER);
    console.log("NEW OWNER: ", NEW_OWNER);
    console.log("RECIPIENT: ", RECIPIENT);
    console.log("ANOTHER ACCOUNT:", ANOTHER_ACCOUNT);

    var testAccounts = [NEW_OWNER, ANOTHER_ACCOUNT];


    beforeEach(async function () {
       this.token = await ShareToken.new();

       this.mainsale = await MainSale.new(constants.ETH_USD_RATE, this.token.address);

       // set ico
       await this.token.setIcoContract(this.mainsale.address);

       for (var i=0; i < accounts.length; i++){
           await this.token.set(accounts[i]);
       }
    });

    it('Total issued mainsale token should be initially 0', async function(){
        var res = await this.token.totalMainSaleTokenIssued();
        assert.equal(res, 0);
    })

    it('Total remaining mainsale token should be intially cap value', async function(){
        var res = await this.mainsale.remainingTokensForSale();
        console.log("RemainingToken", res)

        assert.equal(res.toNumber(), constants.TOTAL_MAINSALE);
    })

    it('Token purchase is only allowed during ICO', async function(){
       // ICO is on by default, this should work
        this.mainsale.sendTransaction({from: ANOTHER_ACCOUNT, value: toWei(constants.TEST_BALANCE)});

        // turn off ICO
        this.mainsale.stopICO()

        await assertRevert(this.mainsale.sendTransaction({from: ANOTHER_ACCOUNT,
                                                           value: toWei(constants.TEST_BALANCE)}));

    })

    it('Only owner can withdraw', async function(){
        await assertRevert(this.mainsale.withdrawToOwner({from: ANOTHER_ACCOUNT}));
    })


    it('Withdraw the correct amount', async function(){
        // send some value
        this.mainsale.sendTransaction({from: ANOTHER_ACCOUNT, value: toWei(constants.TEST_BALANCE)});


        
        // check balance
        const balanceBefore = await getWeiBalance(this.mainsale.address);

        const tx = await this.mainsale.withdrawToOwner();

        // check balance
        const balanceAfter = await getWeiBalance(this.mainsale.address);

        assert.equal(balanceAfter, 0);
        assert.equal(balanceBefore, toWei(constants.TEST_BALANCE));

    })
       
});
