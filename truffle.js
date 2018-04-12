require("babel-register");
require("babel-polyfill");

var HDWalletProvider = require("truffle-hdwallet-provider");

var mnemonic = "become manage bind life remove tiger grief between smile enlist settle message";

module.exports = {
  // See <http://truffleframework.com/docs/advanced/configuration>
  // to customize your Truffle configuration!
  networks: {
    development: {
      // host: "127.0.0.1",
      // port: 8545,
      provider: function() {
          return new HDWalletProvider(mnemonic, "http://127.0.0.1:8545/", 0);
      },
      network_id: "*", // Match any network id
      gas: 4500000
    },
    ropsten: {
      provider: function() {
        return new HDWalletProvider(mnemonic, "https://ropsten.infura.io/aJvbn5wE7F3LNgkrlkyR", 0)
      },
      network_id: 3,
      gas: 4500000,
      // gas: 4717412,
      // gasPrice: 20000000000,
      // from: "0x6582ca80677F3AcDFc8AeaabbEd0550B31Ee0F02"
    },
    rinkeby: {
        provider: function() {
            return new HDWalletProvider( mnemonic, 'https://rinkeby.infura.io/KD0tyiBLlHULRInWEMaJ', 0)
        },
        network_id: 4,
        gas: 6712388,
        gasPrice: 1000000000 
    }
  }
};
