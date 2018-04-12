var Global = function () {}

Global.globalize = function () {

    global.OWNER_ADDR = '0x5409ed021d9299bf6814279a6a1411a7e866a631';
    global.PRIV_KEY = 'f2f48ee19680706196e2e339e5da3491186e0c4c5030670656b0e0164837257d';
    global.SHARE_TOKEN_CONTRACT_ADDR = '0xbe0037eaf2d64fe5529bca93c18c9702d3930376';

    // Reference to the deployed contract via its address
    var ShrToken = artifacts.require('./ShareToken.sol');
    var ShrTokenContractABI = require('./../build/contracts/ShareToken.json').abi;
    var ShrTokenContract = web3.eth.contract(ShrTokenContractABI);
    global.ShrTokenObj = ShrTokenContract.at(SHARE_TOKEN_CONTRACT_ADDR);

}

module.exports = Global;