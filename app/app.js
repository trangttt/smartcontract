const ShareToken = artifacts.require('ShareToken');

global.artifacts = artifacts;
global.web3 = web3;

var utils = require('./utils');

require('./global').globalize();
var dat = require('./data/output/data1');

const UNLOCK_ERROR = 'Cannot unlock account.';
const GASPRICE_ERROR = 'Cannot get gasPrice.';
const NONCE_ERROR = 'Cannot get nonce.';

var shrTokenContractAddr = "0xaa1976ffd82ea38244e532f520790b987608f436";

ShareToken.at(shrTokenContractAddr).
    then(function(instance){
        SHRContract = instance;
        console.log("ShareToken: ", SHRContract.address);
        return SHRContract.totalSupply();
    }).then(function(res){
        console.log("TotalSupply:", res.toNumber());
        return web3.eth.getGasPrice(function(err, res){
            console.log("Gas Price:", res.toNumber());
            gasPrice = res.toNumber();
        });
    }).then(function(){
        return SHRContract.handlePresaleTokenMany(dat.addrList, dat.tokenList);
    }).then(function(tx){
        console.log("Tx:", tx);
    });

module.exports = function (deployer) {}
