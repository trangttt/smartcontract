global.artifacts = artifacts;
global.web3 = web3;

var utils = require('./utils');

require('./global').globalize();

const UNLOCK_ERROR = 'Cannot unlock account.';
const GASPRICE_ERROR = 'Cannot get gasPrice.';
const NONCE_ERROR = 'Cannot get nonce.';

var testAddr = '0x6ecbe1db9ef729cbe972c83fb886247691fb6beb';
var testAmount = 100;

// Unlock the owner wallet address
var er = utils.unlock(global.OWNER_ADDR, global.PRIV_KEY);
if (er) {
    console.error(UNLOCK_ERROR);
}
else {
    // Get gas price
    var gasPrice = utils.getGasPrice();
    if (!gasPrice) {
        console.error(GASPRICE_ERROR);
    }
    else {
        // Get nonce
        var nonce = utils.getNonce(global.OWNER_ADDR, 'latest');
        if (!nonce && nonce != 0) {
            console.error(NONCE_ERROR);
        }
        else {
            global.ShrTokenObj.handlePresaleToken(testAddr, testAmount, {
                from: global.OWNER_ADDR,
                gas: 2100000,
                gasPrice: gasPrice,
                nonce: nonce
            }, function (er, tx) {
                if (er) {
                    console.error('handlePresaleToken failed - err: ' + er);
                }
                else {
                    console.log('handlePresaleToken OK -  txId: ' + tx);
                }
            })
        }
    }
}

module.exports = function (deployer) {}
    