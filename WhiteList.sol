pragma solidity ^0.4.16;

contract WhiteList {

    // Any token amount must be multiplied by this const to reflect decimals
    uint constant E2 = 10**2;

    struct Checkpoint {

        uint tokens;
        bool exist;
    }

    mapping (address => Checkpoint) public list;

    function WhiteList() public {

    }

    function unset(address addr) public {

        list[addr].exist = false;
        list[addr].tokens = 0;
    }

    function set(address addr, uint tokenAmount) public {

        require(addr != address(0x0));
        list[addr] = Checkpoint({
                        tokens:tokenAmount,
                        exist:true
                     });
    }

    function isWhitelisted(address addr) returns (bool) {

        return list[addr].exist;
    }
}