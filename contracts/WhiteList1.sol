pragma solidity ^0.4.16;

import "./WhiteListManager.sol";
import "./ShareToken.sol";

contract WhiteList1 {

    // Any token amount must be multiplied by this const to reflect decimals
    uint constant E2 = 10**2;

    function WhiteList1(address whitelistManagerAddr, address shrTokenAddr) public {

        WhiteListManager wlm = WhiteListManager(whitelistManagerAddr);
        ShareToken shrToken = ShareToken(shrTokenAddr);

        wlm.set(0x175FeA8857f7581B971C5a41F27Ea4BB43356298);
        shrToken.transferSeedToken(0x175FeA8857f7581B971C5a41F27Ea4BB43356298, 100 * E2);

        wlm.set(0x94Ae4F5323737DD8e06EE295c49bb5C871E4eB2f);
        shrToken.transferSeedToken(0x94Ae4F5323737DD8e06EE295c49bb5C871E4eB2f, 200 * E2);
    }
}