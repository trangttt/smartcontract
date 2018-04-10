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

    //*****************************************************************************************
    //                          INITIAL STATUS TESTCASES
    //*****************************************************************************************

    it('Intial supply should be 0', async function(){
          const totalSupply = await this.token.totalSupply();
          assert.equal(totalSupply.toNumber(), 0);
    })

    it('Owner should be the address which deployed the contract', async function(){
        const owner = await this.token.owner();
        assert.equal(owner, OWNER);
    })

    it('Initially, balance should be ZERO', async function(){
        const balance = await this.token.balanceOf(ANOTHER_ACCOUNT);
        assert.equal(balance.toNumber(), 0);
    })
    
    //*****************************************************************************************
    //                          ZERO ADDRESS TESTCASES
    //*****************************************************************************************
    
    it('Approve a ZERO address must revert', async function(){
        //const balance = await this.token.balanceOf(OWNER);
        //console.log("Balance of OWNER:", balance.toNumber());
        //const tx = await this.token.approve(constants.ZERO_ADDRESS, 0);
        //const allowance = await this.token.allowance(OWNER, constants.ZERO_ADDRESS);
        //console.log("ALLOWANCE: ", allowance.toNumber());
        await assertRevert.assertRevert(this.token.approve(constants.ZERO_ADDRESS, 0));
    })

    it('Transfer to a ZERO address must revert', async function(){
        await assertRevert.assertRevert(this.token.approve(constants.ZERO_ADDRESS, 0));
    })

    it('Transfer from a ZERO ADDRESSS must revert', async function(){
        await assertRevert.assertRevert(this.token.transfer(constants.ZERO_ADDRESS, 0));
    })

    it('Sell to an ZERO address must revert', async function(){
        await assertRevert.assertRevert(this.token.sell(constants.ZERO_ADDRESS, 0));
    })

    //*****************************************************************************************
    //                          SELL TESTCASES
    //*****************************************************************************************
    
    it('Sell to an address, check balance', async function(){
        // sell some tokens to ANOTHER_ACCOUNT
        const balanceAfter = await sellToAccount(this.token, ANOTHER_ACCOUNT, constants.TEST_BALANCE);

        // check balance of ANOTHER_ACCOUNT
        assert.equal(balanceAfter, constants.TEST_BALANCE);
    })


    it('Sell and then transfer locked token should fail', async function(){
        const balanceAfter = await sellToAccount(this.token, ANOTHER_ACCOUNT, constants.TEST_BALANCE);

        // check balance of ANOTHER_ACCOUNT
        assert.equal(balanceAfter, constants.TEST_BALANCE);
        await assertRevert.assertRevert(this.token.transfer(OWNER, constants.TEST_BALANCE, 
                                                            {from: ANOTHER_ACCOUNT}))
    })


    it('Unlocked tokens should be transferable', async function(){
        const balanceAfter = await sellToAccount(this.token, ANOTHER_ACCOUNT, constants.TEST_BALANCE);

        // check balance of ANOTHER_ACCOUNT
        assert.equal(balanceAfter, constants.TEST_BALANCE);
        
        // Unlock 
        const tx = await this.token.unLock(ANOTHER_ACCOUNT);

        // Transfer
        const tx1 = await this.token.transfer(NEW_OWNER, constants.TEST_BALANCE, {from: ANOTHER_ACCOUNT})

        // check account balances
        const anotherBalance = await getBalance(this.token, ANOTHER_ACCOUNT)
        const ownerBalance = await getBalance(this.token, NEW_OWNER)
        assert.equal(anotherBalance, 0);
        assert.equal(ownerBalance, constants.TEST_BALANCE)

    })

    //*****************************************************************************************
    //                         TRANSFER_FROM TESTCASES 
    //*****************************************************************************************
    
    it('Transfer from an EMPTY account must revert', async function(){
        await assertRevert.assertRevert(this.token.transfer(NEW_OWNER, constants.TEST_BALANCE),
                                                            {from: ANOTHER_ACCOUNT})
    })

    it('Transfer from an account without approval', async function(){
        await assertRevert.assertRevert(this.token.transferFrom(NEW_OWNER,
                                                                ANOTHER_ACCOUNT,
                                                                constants.TEST_BALANCE))
    })

    it('Transfer from account with insufficient balance', async function(){
        // deposit some tokens to ANOTHER_ACCOUNT
        await sellToAccount(this.token, ANOTHER_ACCOUNT, constants.TEST_BALANCE)

        // ANOTHER_ACCOUNT approve OWNER 3 token
        const tx = await this.token.approve(OWNER, constants.TEST_BALANCE,
                                            {from: ANOTHER_ACCOUNT})

        // unLock so tokens are transferable
        await this.token.unLock(ANOTHER_ACCOUNT);
        await this.token.unLock(OWNER);

        await assertRevert.assertRevert(this.token.transferFrom(ANOTHER_ACCOUNT, NEW_OWNER, 4))
    })

    it('Transfer from account with sufficient balance', async function(){
        // deposit some token to OWNER
        await sellToAccount(this.token, OWNER, constants.TEST_BALANCE);
        assert.equal(await getBalance(this.token, OWNER), constants.TEST_BALANCE);

        // approve  ANOTHER_ACCOUNT to spend
        const tx0 = await this.token.approve(ANOTHER_ACCOUNT, constants.TEST_BALANCE);

        // unLock so tokens are transferable
        await this.token.unLock(ANOTHER_ACCOUNT);
        await this.token.unLock(OWNER);

        // transfer from ANOTHER_ACCOUNT, using OWNER BALANCE should work
        const tx = await this.token.transferFrom(OWNER, NEW_OWNER, constants.TEST_BALANCE, 
                                                {from: ANOTHER_ACCOUNT})

        // checking new balance
        assert.equal(await getBalance(this.token, OWNER), 0)
    })

    //*****************************************************************************************
    //                        ABSURDLY LARGE AMOUNT OF TOKENS TESTCASES
    //*****************************************************************************************

    it('Sell an absurdly large amount of token should fail', async function(){
        await assertRevert.assertRevert(this.token.sell(ANOTHER_ACCOUNT, constants.LARGER_THAN_TOTAL))
    })

    it('Transfer an absurdly large amount of token should fail', async function(){
        await assertRevert.assertRevert(this.token.transfer(ANOTHER_ACCOUNT, constants.LARGER_THAN_TOTAL))
    })

    it('Approve an absurdly large amount of token should fail', async function(){
        await assertRevert.assertRevert(this.token.approve(ANOTHER_ACCOUNT, constants.LARGER_THAN_TOTAL), 
                                                            {from: OWNER});
    })
    
    it('Transfer from an account to another with an absurdly large amount of token should fail',
        async function(){
        await assertRevert.assertRevert(this.token.transferFrom(ANOTHER_ACCOUNT, NEW_OWNER, constants.LARGER_THAN_TOTAL))
    })
});