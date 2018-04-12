var Global = function () {}

Global.globalize = function () {

    global.OWNER_ADDR = '0x22d6eaf11803e99ca90603cac1d50ba47c96a210';
    global.PRIV_KEY = 'bc20b268694c66e8d506c6dfdc9a90fdeb9d668104b19cc1ddc8bd3a16f52dbd';
    global.SHARE_TOKEN_CONTRACT_ADDR = '0xedd07cafaaaa3370f756da6d1463c247177b50b2';

    // Reference to the deployed contract via its address
    var ShrToken = artifacts.require('./ShareToken.sol');
    var ShrTokenContractABI = require('./../build/contracts/ShareToken.json').abi;
    var ShrTokenContract = web3.eth.contract(ShrTokenContractABI);
    global.ShrTokenObj = ShrTokenContract.at(SHARE_TOKEN_CONTRACT_ADDR);

}

module.exports = Global;