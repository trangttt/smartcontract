const ShareToken = artifacts.require('ShareToken');

var Global = function () {}

Global.globalize = function () {

    global.OWNER_ADDR = "0x175FeA8857f7581B971C5a41F27Ea4BB43356298";
    global.PRIV_KEY = "c548e41cdc3f372995820c3d52fc470b2b380e1bce2a86be017b50e2f2fe82ee";
    global.SHARE_TOKEN_CONTRACT_ADDR = "0x3472eca8d2a781dbe18378558d82eb286e5d3534";

    // Reference to the deployed contract via its address
    //var ShrToken = artifacts.require('./ShareToken.sol');
    //var ShrTokenContractABI = require('./../build/contracts/ShareToken.json').abi;
    //var ShrTokenContract = web3.eth.contract(ShrTokenContractABI);
    //global.ShrTokenObj = ShrTokenContract.at(SHARE_TOKEN_CONTRACT_ADDR);
    global.ShrTokenObj;
    ShareToken.deployed().then(function(instance){
        global.ShrTokenObj = instance;
        console.log("ShareToken: ", global.ShrTokenObj.address);
    });

}

module.exports = Global;
