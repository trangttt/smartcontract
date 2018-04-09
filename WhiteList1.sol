pragma solidity ^0.4.16;
import "./WhiteList.sol";

contract WhiteList1 is WhiteList {

    function WhiteList1() public {

        set(0x175FeA8857f7581B971C5a41F27Ea4BB43356298, 1000 * E2);
        set(0xFb2e63ABeBCB0A75c03A6BE27b89fC5E38751986, 2000 * E2);
    }
}