var request = require('request');

/**
 * Declare class
 * @class Utils
 */
var Utils = function () {}

Utils.unlock = function (address, password) {
    web3.personal.unlockAccount(address, password, function (er, re) {
        return er;
    });
}

Utils.isAddress = function (address) {
    try {
        return web3.isAddress(address);
    } catch (er) {
        return false;
    }
}

Utils.isJSON = function (s) {
    try {
        JSON.parse(s);
        return true;
    } catch (e) {
        return false;
    }
}

Utils.parseJSON = function (s) {
    try {
        s = JSON.parse(s);
        return s;
    } catch (e) {
        return null;
    }
}

Utils.httpGet = function (router, callback) {
    var self = this;
    request.get(router, (er, res, body) => {
        if (er) return callback(er, null);
        if (!self.isJSON(body)) return callback(ERROR, null);
        body = JSON.parse(body);
        return callback(null, body);
    });
}

Utils.sortArray = function (array, key, decrease) {
    return array.sort(function (a, b) {
        if (decrease) return b[key] - a[key];
        return a[key] - b[key];
    });
}

Utils.getGasPrice = function () {
    try {
        return (web3.eth.gasPrice.toString(10));
    } catch (er) {
        return (null);
    }
}

Utils.getNonce = function (address, status) {
    try {
        var actualStatus = status || 'latest';
        return web3.eth.getTransactionCount(address, actualStatus);
    } catch (er) {
        return null;
    }
}

Utils.getBlockNumber = function () {
    try {
        return web3.eth.blockNumber;
    } catch (er) {
        return null;
    }
}

module.exports = Utils;