pragma solidity ^0.4.16;

import "./WhiteList.sol";
import "./Owned.sol";

contract WhiteListManager is Owned {

    WhiteList[] whitelist;

    event IsWhiteList(bool res);

    function WhiteListManager() public {

    }

    function setDeployedWhiteList(address[] _whitelist) onlyOwner {

        for (uint i = 0; i < _whitelist.length; i++) {
            
            whitelist.push(WhiteList(_whitelist[i]));
        }
    }

    function isWhitelisted(address addr) returns (bool) {

        for (uint i = 0; i < whitelist.length; i++) {
            
            if (whitelist[i].isWhitelisted(addr)) {
                emit IsWhiteList(true);
                return true;
            }
        }

        emit IsWhiteList(false);
        return false;
    }
}