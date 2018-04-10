pragma solidity ^0.4.16;

import "./WhiteListManager.sol";
import "./ShareToken.sol";

contract WhiteList2 {

    // Any token amount must be multiplied by this const to reflect decimals
    uint constant E2 = 10**2;

    function WhiteList2(address whitelistManagerAddr, address shrTokenAddr) public {

        WhiteListManager wlm = WhiteListManager(whitelistManagerAddr);
        ShareToken shrToken = ShareToken(shrTokenAddr);

        wlm.set(0x22D6EAf11803E99ca90603cAC1D50BA47c96a210);
        shrToken.transferSeedToken(0x22D6EAf11803E99ca90603cAC1D50BA47c96a210, 100 * E2);

        wlm.set(0xc72a04134095273d5bFf6f6651e9b1F9251451DE);
        shrToken.transferSeedToken(0xc72a04134095273d5bFf6f6651e9b1F9251451DE, 200 * E2);
    }
}