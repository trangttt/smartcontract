var ShareToken = artifacts.require("./ShareToken.sol");
var MainSale = artifacts.require("./MainSale.sol");
var WhiteListManager = artifacts.require("./WhitelistManager");

module.exports = function(deployer) {
  var stAddr;
  deployer.deploy(WhiteListManager).then(function(){
    return deployer.deploy(ShareToken, WhiteListManager.address).then(function(){
      console.log('SHARE TOKEN', ShareToken.address);
      return deployer.deploy(MainSale, 40000, ShareToken.address);
    });
  }); 
};
