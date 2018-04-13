pragma solidity ^0.4.21;

import "./oraclizeAPI_0.5.sol";
import "./Owned.sol";
import "./SafeMath.sol";
import "./ShareToken.sol";


contract MainSale is Owned, usingOraclize {
    
    using SafeMath for uint;

    ShareToken public shrToken;

    // Any token amount must be multiplied by this const to reflect decimals
    uint constant E2 = 10**2;

    bool public isIcoRunning = true;
    
    bool public isUpdateRateRunning = true;

    uint public tokenPriceInCent = 2; // cent or $0.02
    uint public ethUsdRateInCent = 0;// cent

    uint public constant TOKEN_SUPPLY_MAINSALE_LIMIT = 1000000000 * E2; // 1,000,000,000 tokens (1 billion)

    uint public constant ETH_USD_UPDATE_PERIOD = 86400; // 24 * 60 * 60 (for every 24 hours) 

    // Must pre-deploy the ShareToken contract to get its address
    // Must supply the ETH/USD rate (in cent) upon token creation
    function MainSale(uint _ethUsdRateInCent, address _tokenAddress) public payable {

        require(_ethUsdRateInCent > 0);
        require(_tokenAddress != address(0x0));

        ethUsdRateInCent = _ethUsdRateInCent;

        shrToken = ShareToken(_tokenAddress);

        // updateRate();
    }

    /* Allow whitelisted users to send ETH to token contract for buying tokens */
    function () public payable {
        require (isIcoRunning);

        // Only whitelisted address can buy tokens. Otherwise, refund
        require (shrToken.isWhitelisted(msg.sender));

        // if (isUpdateRateRunning == false) {
            
        //     updateRate();
        // }
        
        uint tokens = 0;

        // Calc the transferred amount in cents (msg.value is in wei and thus divided by 10^18 to get ETH)
        // uint transferredAmount = msg.value.mul(ethUsdRateInCent).div(10**18);

        // Calc the token amount
        // tokens = transferredAmount.div(tokenPriceInCent) * E2;

        tokens = msg.value.mul(ethUsdRateInCent).mul(E2).div(tokenPriceInCent).div(10**18);

        uint totalIssuedTokens = shrToken.totalMainSaleTokenIssued();

        // If the allocated tokens exceed the limit, must refund to user
        if (totalIssuedTokens.add(tokens) > TOKEN_SUPPLY_MAINSALE_LIMIT) {

            uint tokensAvailable = TOKEN_SUPPLY_MAINSALE_LIMIT.sub(totalIssuedTokens);
            uint tokensToRefund = tokens.sub(tokensAvailable);
            uint ethToRefundInWei = tokensToRefund.mul(10**18).div(tokenPriceInCent).div(ethUsdRateInCent);
            
            // Refund
            msg.sender.transfer(ethToRefundInWei);

            // Update actual tokens to be sold
            tokens = tokensAvailable;

            // Stop ICO
            isIcoRunning = false;
        }

        shrToken.sell(msg.sender, tokens);
    }

    function withdrawToOwner() public onlyOwner {

        owner.transfer(address(this).balance);
    }

    function withdrawTo(address _to) public onlyOwner {

        _to.transfer(address(this).balance);
    }

    function setEthUsdRateInCent(uint _ethUsdRateInCent) public onlyOwner {
        
        ethUsdRateInCent = _ethUsdRateInCent; // "_ethUsdRateInCent"
    }

    /* Transfer out any accidentally sent ERC20 tokens */
    function transferAnyERC20Token(address tokenAddress, uint amount) public onlyOwner returns (bool success) {

        return ERC20Interface(tokenAddress).transfer(owner, amount);
    }

    function stopICO() public onlyOwner {

        isIcoRunning = false;
    }

    function startICO() public onlyOwner {

        isIcoRunning = true;
    }

    function remainingTokensForSale() public view returns (uint) {
        
        return TOKEN_SUPPLY_MAINSALE_LIMIT.sub(shrToken.totalMainSaleTokenIssued());
    }

    function __callback(bytes32 myid, string result) public {
        
        // Never use require right here. It won't work!
        if (msg.sender != oraclize_cbAddress()) throw;
        ethUsdRateInCent = parseInt(result, 2);
        
        if (isIcoRunning == true) {
            updateRate();
        } else {
            isUpdateRateRunning = false;
        }
    }

    function updateRate() public payable onlyOwner {

        if (oraclize_getPrice("URL") <= address(this).balance) {
            // Get rate with delay
            oraclize_query(ETH_USD_UPDATE_PERIOD, "URL", "json(https://api.gdax.com/products/ETH-USD/ticker).price");
            isUpdateRateRunning = true;
        } else {
            isUpdateRateRunning = false;
        }
    }
}
