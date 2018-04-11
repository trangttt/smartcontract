var ShareToken = artifacts.require("./ShareToken.sol");
var MainSale = artifacts.require("./MainSale.sol");
var WhiteListManager = artifacts.require("./WhitelistManager");

module.exports = function(deployer) {
  var stAddr;

  deployer.deploy(ShareToken).then(function(){
    console.log('SHARE TOKEN', ShareToken.address);
    return deployer.deploy(MainSale, 40000, ShareToken.address).then(function(result){
        console.log('MAINSALE', MainSale.address);
        return deployer.deploy(WhiteListManager);
    })
  }); 
};
