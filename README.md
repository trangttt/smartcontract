# Instruction

## Installation

npm install

## Run test

npm test <test_file>

## Feed presale data

* npm run testrpc
* npm run rinkeby
* npm run mainnet

# MainSale Contracts Testcases

The contracts are tested using [Truffle Framework](http://truffleframework.com/docs/getting_started/) under TestRPC.

## QUICK START

* Please install Truffle using *npm* as described [here](http://truffleframework.com/)
* Install TestRPC or new Ganache as described [here](https://github.com/trufflesuite/ganache-cli)
* Run TestRPC/Ganache as Ethereum network and expose port *8545* under *127.0.0.1* (These should be default options).
* Run `truffle test <test_file>` for each test file. They are located under `test/token` folder.

**NOTE**:

* Please test each file under folder *test/token* seperately. 
   * For example: `truffle test test/token/ShareTokenTest.js`
* Please restart TestRPC/Ganache after certain testruns to update testing accounts' balances and states



