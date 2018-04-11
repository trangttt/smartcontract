pragma solidity ^0.4.16;

import "./Owned.sol";

contract WhiteListManager is Owned {

    // The list here will be updated by multiple separate WhiteList contracts
    mapping (address => bool) public list;

    bool public setWhitelistEnabled = true;

    function WhiteListManager() public {

    }

    function enableSetWhitelist() public onlyOwner {

        setWhitelistEnabled = true;
    }

    function disableSetWhitelist() public onlyOwner {

        setWhitelistEnabled = false;
    }

    function unset(address addr) public {

        require(setWhitelistEnabled);
        require(addr != address(0x0));
        list[addr] = false;
    }

    function unsetMany(address[] addrList) public {

        for (uint i = 0; i < addrList.length; i++) {
            
            unset(addrList[i]);
        }
    }

    function set(address addr) public {

        require(setWhitelistEnabled);
        require(addr != address(0x0));
        list[addr] = true;
    }

    function setMany(address[] addrList) public {

        for (uint i = 0; i < addrList.length; i++) {
            
            set(addrList[i]);
        }
    }

    function isWhitelisted(address addr) public returns (bool) {

        return list[addr];
    }
}