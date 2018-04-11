pragma solidity ^0.4.16;

import "./Owned.sol";

contract WhiteListManager is Owned {

    // The list here will be updated by multiple separate WhiteList contracts
    mapping (address => bool) public list;

    function WhiteListManager() public {

    }

    function unset(address addr) public onlyOwner {

        require(addr != address(0x0));
        list[addr] = false;
    }

    function unsetMany(address[] addrList) public onlyOwner {

        for (uint i = 0; i < addrList.length; i++) {
            
            if (addrList[i] != address(0x0)) {
                list[addrList[i]] = false;
            }
        }
    }

    function set(address addr) public onlyOwner {

        require(addr != address(0x0));
        list[addr] = true;
    }

    function setMany(address[] addrList) public {

        for (uint i = 0; i < addrList.length; i++) {
            
            if (addrList[i] != address(0x0)) {
                list[addrList[i]] = true;
            }
        }
    }

    function isWhitelisted(address addr) public returns (bool) {

        return list[addr];
    }
}