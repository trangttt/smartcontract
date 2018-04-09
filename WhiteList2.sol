pragma solidity ^0.4.16;
import "./WhiteList.sol";

contract WhiteList2 is WhiteList {

    function WhiteList2() public {

        set(0x175FeA8857f7581B971C5a41F27Ea4BB43356298, 1000 * E2);
        set(0x94Ae4F5323737DD8e06EE295c49bb5C871E4eB2f, 2000 * E2);
    }
}