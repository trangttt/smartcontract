global.artifacts = artifacts;
global.web3 = web3;

var utils = require('./utils');

require('./global').globalize();
var dat = require('./data1');

const UNLOCK_ERROR = 'Cannot unlock account.';
const GASPRICE_ERROR = 'Cannot get gasPrice.';
const NONCE_ERROR = 'Cannot get nonce.';

// Unlock the owner wallet address
utils.unlock(global.OWNER_ADDR, global.PRIV_KEY, function (re) {
    if (!re) {
        console.error(UNLOCK_ERROR);
    }
    else {
        utils.getGasPrice(function (gasPrice) {
            if (!gasPrice) {
                console.error(GASPRICE_ERROR);
            }
            else {
                utils.getNonce(global.OWNER_ADDR, 'latest', function (nonce) {
                    if (!nonce) {
                        console.error(NONCE_ERROR);
                    }
                    else {
                        global.ShrTokenObj.handlePresaleTokenMany(dat.addrList, dat.tokenList, {
                            from: global.OWNER_ADDR,
                            gas: 21000000,
                            gasPrice: gasPrice,
                            nonce: nonce
                        }, function (er, tx) {
                            if (er) {
                                console.error('handlePresaleTokenMany failed - err: ' + er);
                            }
                            else {
                                console.log('handlePresaleTokenMany OK -  txId: ' + tx);
                            }
                        });
                    }
                });
            }
        });
    }
});

module.exports = function (deployer) {}
    