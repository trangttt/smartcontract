var ShareToken = artifacts.require("./ShareToken.sol");

module.exports = function(deployer) {
  deployer.deploy(ShareToken);
};
