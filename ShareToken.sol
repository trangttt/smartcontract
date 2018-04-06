pragma solidity ^0.4.16;

import "./oraclizeAPI_0.5.sol";

library SafeMath {

    function mul(uint256 a, uint256 b) internal constant returns (uint256) {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }
    function div(uint256 a, uint256 b) internal constant returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }
    function sub(uint256 a, uint256 b) internal constant returns (uint256) {
        assert(b <= a);
        return a - b;
    }
    function add(uint256 a, uint256 b) internal constant returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}

contract Owned {

    address public owner;
    address public newOwner;

    event OwnershipTransferProposed(address indexed _from, address indexed _to);
    event OwnershipTransferred(address indexed _from, address indexed _to);

    modifier onlyOwner {
        require( msg.sender == owner );
        _;
    }

    function Owned() public {
        owner = msg.sender;
    }

    function transferOwnership(address _newOwner) onlyOwner {
        require( _newOwner != owner );
        require( _newOwner != address(0x0) );
        OwnershipTransferProposed(owner, _newOwner);
        newOwner = _newOwner;
    }

    function acceptOwnership() {
        require(msg.sender == newOwner);
        OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }
}

contract ERC20Interface {

    event Transfer(address indexed _from, address indexed _to, uint _value);
    event Approval(address indexed _owner, address indexed _spender, uint _value);

    function totalSupply() constant returns (uint);
    function balanceOf(address _owner) constant returns (uint balance);
    function transfer(address _to, uint _value) returns (bool success);
    function transferFrom(address _from, address _to, uint _value) returns (bool success);
    function approve(address _spender, uint _value) returns (bool success);
    function allowance(address _owner, address _spender) constant returns (uint remaining);
}

contract ERC20Token is ERC20Interface {

    using SafeMath for uint;

    // Total amount of tokens issued
    uint internal totalTokenIssued;

    mapping(address => uint) balances;
    mapping(address => mapping (address => uint)) allowed;

    function totalSupply() constant returns (uint) {
        return totalTokenIssued;
    }

    /* Get the account balance for an address */
    function balanceOf(address _owner) constant returns (uint balance) {
        return balances[_owner];
    }

    /* Transfer the balance from owner's account to another account */
    function transfer(address _to, uint _amount) returns (bool success) {
        // amount sent cannot exceed balance
        require( balances[msg.sender] >= _amount );

        // update balances
        balances[msg.sender] = balances[msg.sender].sub(_amount);
        balances[_to]        = balances[_to].add(_amount);

        // log event
        Transfer(msg.sender, _to, _amount);
        return true;
    }

    /* Allow _spender to withdraw from your account up to _amount */
    function approve(address _spender, uint _amount) returns (bool success) {
        // approval amount cannot exceed the balance
        require ( balances[msg.sender] >= _amount );
          
        // update allowed amount
        allowed[msg.sender][_spender] = _amount;
        
        // log event
        Approval(msg.sender, _spender, _amount);
        return true;
    }

    /* Spender of tokens transfers tokens from the owner's balance */
    /* Must be pre-approved by owner */
    function transferFrom(address _from, address _to, uint _amount) returns (bool success) {
        // balance checks
        require( balances[_from] >= _amount );
        require( allowed[_from][msg.sender] >= _amount );

        // update balances and allowed amount
        balances[_from]            = balances[_from].sub(_amount);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_amount);
        balances[_to]              = balances[_to].add(_amount);

        // log event
        Transfer(_from, _to, _amount);
        return true;
    }

    /* Returns the amount of tokens approved by the owner */
    /* that can be transferred by spender */
    function allowance(address _owner, address _spender) constant returns (uint remaining) {
        return allowed[_owner][_spender];
    }
}

contract WhitelistedCrowdsale is Owned {

    using SafeMath for uint256;

    // Manage the whitelist addr
    mapping (address => bool) whitelist;
    address[] whitelistAddresses;

    function addToWhitelist(address buyer) public onlyOwner {
        require(buyer != 0x0);
        whitelist[buyer] = true;
        whitelistAddresses.push(buyer);
    }

    function addManyToWhitelist(address[] buyerList) public onlyOwner {
        
        for (uint i = 0; i < buyerList.length; i++) {
            if (buyerList[i] != 0x0) {
                whitelist[buyerList[i]] = true;
                whitelistAddresses.push(buyerList[i]);
            }
        }
    }

    function isWhitelisted(address buyer) public constant returns (bool) {
        return whitelist[buyer];
    }
}

contract ShareToken is ERC20Token, Owned {

    using SafeMath for uint;

    string public constant name = "ShareToken";
    string public constant symbol = "SHR";
    uint8  public constant decimals = 2;

    // Any token amount must be multiplied by this const to reflect decimals
    uint constant E2 = 10**2;

    mapping(address => bool) locked;

    uint public constant TOKEN_SUPPLY_AIRDROP_LIMIT  = 6666666667; // 66,666,666.67 tokens (0.066 billion)
    uint public constant TOKEN_SUPPLY_BOUNTY_LIMIT   = 33333333333; // 333,333,333.33 tokens (0.333 billion)

    uint public airDropTokenIssuedTotal;
    uint public bountyTokenIssuedTotal;

    uint public constant TOKEN_SUPPLY_SEED_LIMIT      = 500000000 * E2; // 500,000,000 tokens (0.5 billion)
    uint public constant TOKEN_SUPPLY_PRESALE_LIMIT   = 2500000000 * E2; // 2,500,000,000.00 tokens (2.5 billion)

    uint public seedTokenIssuedTotal;
    uint public presaleTokenIssuedTotal;

    function ShareToken() public {

        totalTokenIssued = 0;
        airDropTokenIssuedTotal = 0;
        bountyTokenIssuedTotal = 0;
        seedTokenIssuedTotal = 0;
        presaleTokenIssuedTotal = 0;
    }

    function transfer(address _to, uint _amount) returns (bool success) {

        require( locked[msg.sender] == false );    
        require( locked[_to] == false );
        
        return super.transfer(_to, _amount);
    }

    function transferFrom(address _from, address _to, uint _amount) returns (bool success) {
        
        require( locked[_from] == false );
        require( locked[_to] == false );

        return super.transferFrom(_from, _to, _amount);
    }

    function unLock(address _participant) onlyOwner {

        locked[_participant] = false;
    }

    function unLockMultiple(address[] _participants) onlyOwner {

        for (uint i = 0; i < _participants.length; i++) {
            locked[_participants[i]] = false;
        }
    }

    function sell(address buyer, uint tokens) onlyOwner returns (bool success) {
      
        require (tokens > 0);

        // Register tokens issued to the buyer
        balances[buyer] = balances[buyer].add(tokens);

        // Update total amount of tokens issued
        totalTokenIssued = totalTokenIssued.add(tokens);

        // Lock the buyer
        locked[msg.sender] = true;

        Transfer(address(0x0), buyer, tokens);

        return true;
    }

    function rewardAirdrop(address _to, uint _amount) onlyOwner {

        require(airDropTokenIssuedTotal < TOKEN_SUPPLY_AIRDROP_LIMIT);

        uint remainingTokens = TOKEN_SUPPLY_AIRDROP_LIMIT.sub(airDropTokenIssuedTotal);
        if (_amount > remainingTokens) {
            _amount = remainingTokens;
        }

        // Register tokens to the receiver
        balances[_to] = balances[_to].add(_amount);

        // Update total amount of tokens issued
        airDropTokenIssuedTotal = airDropTokenIssuedTotal.add(_amount);

        // Lock the receiver
        locked[_to] = true;

        Transfer(address(0x0), _to, _amount);
    }

    function rewardBounty(address _to, uint _amount) onlyOwner {

        require(bountyTokenIssuedTotal < TOKEN_SUPPLY_BOUNTY_LIMIT);

        uint remainingTokens = TOKEN_SUPPLY_BOUNTY_LIMIT.sub(bountyTokenIssuedTotal);
        if (_amount > remainingTokens) {
            _amount = remainingTokens;
        }

        // Register tokens to the receiver
        balances[_to] = balances[_to].add(_amount);

        // Update total amount of tokens issued
        bountyTokenIssuedTotal = bountyTokenIssuedTotal.add(_amount);

        // Lock the receiver
        locked[_to] = true;

        Transfer(address(0x0), _to, _amount);
    }

    function transferSeedToken(address _to, uint _amount) onlyOwner {

        require(seedTokenIssuedTotal < TOKEN_SUPPLY_SEED_LIMIT);

        uint remainingTokens = TOKEN_SUPPLY_SEED_LIMIT.sub(seedTokenIssuedTotal);
        require (_amount <= remainingTokens);

        // Register tokens to the receiver
        balances[_to] = balances[_to].add(_amount);

        // Update total amount of tokens issued
        seedTokenIssuedTotal = seedTokenIssuedTotal.add(_amount);

        // Do not lock the seed

        Transfer(address(0x0), _to, _amount);
    }

    function transferSeedTokenMany(address[] addrList, uint[] amountList) onlyOwner {

        require(addrList.length == amountList.length);

        for (uint i = 0; i < addrList.length; i++) {

            transferSeedToken(addrList[i], amountList[i]);
        }
    }

    function transferPreSaleToken(address _to, uint _amount) onlyOwner {

        require(presaleTokenIssuedTotal < TOKEN_SUPPLY_PRESALE_LIMIT);

        uint remainingTokens = TOKEN_SUPPLY_PRESALE_LIMIT.sub(presaleTokenIssuedTotal);
        require (_amount <= remainingTokens);

        // Register tokens to the receiver
        balances[_to] = balances[_to].add(_amount);

        // Update total amount of tokens issued
        presaleTokenIssuedTotal = presaleTokenIssuedTotal.add(_amount);

        // Do not lock the presale

        Transfer(address(0x0), _to, _amount);
    }

    function transferPreSaleTokenMany(address[] addrList, uint[] amountList) onlyOwner {

        require(addrList.length == amountList.length);

        for (uint i = 0; i < addrList.length; i++) {

            transferPreSaleToken(addrList[i], amountList[i]);
        }
    }
}

contract MainSale is WhitelistedCrowdsale, usingOraclize {
    
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
    function MainSale(uint _ethUsdRateInCent, address _tokenAddress) payable {

        require(_ethUsdRateInCent > 0);
        require( _tokenAddress != address(0x0) );

        ethUsdRateInCent = _ethUsdRateInCent;

        shrToken = ShareToken(_tokenAddress);

        updateRate();
    }

    /* Allow whitelisted users to send ETH to token contract for buying tokens */
    function () payable {
        
        if (isIcoRunning == false) {

            msg.sender.transfer(msg.value);
            revert();
        }
        
        // Only whitelisted address can buy tokens. Otherwise, refund
        if (!isWhitelisted(msg.sender)) {

            msg.sender.transfer(msg.value);
            revert();
        }

        if (isUpdateRateRunning == false) {
            
            updateRate();
        }
        
        uint tokens = 0;

        // Calc the transferred amount in cents (msg.value is in wei and thus divided by 10^18 to get ETH)
        uint transferredAmount = msg.value.mul(ethUsdRateInCent).div(10**18);

        // Calc the token amount
        tokens = transferredAmount.div(tokenPriceInCent) * E2;

        uint totalIssuedTokens = shrToken.totalSupply();

        // If the allocated tokens exceed the limit, must refund to user
        if (totalIssuedTokens.add(tokens) > TOKEN_SUPPLY_MAINSALE_LIMIT) {

            uint tokensAvailable = TOKEN_SUPPLY_MAINSALE_LIMIT - totalIssuedTokens;
            uint tokensToRefund = tokens - tokensAvailable;
            uint ethToRefundInWei = tokensToRefund.div(tokenPriceInCent).div(ethUsdRateInCent).mul(10**18);
            
            // Refund
            msg.sender.transfer(ethToRefundInWei);

            // Update actual tokens to be sold
            tokens = tokensAvailable;

            // Stop ICO
            isIcoRunning = false;
        }

        shrToken.sell(msg.sender, tokens);
    }

    function withdrawToOwner() payable {

        require(msg.sender == owner);
        owner.transfer(this.balance);
    }

    function withdrawTo(address _to) payable {

        require(msg.sender == owner);
        _to.transfer(this.balance);
    }

    function setEthUsdRateInCent(uint _ethUsdRateInCent) onlyOwner {
        
        ethUsdRateInCent = _ethUsdRateInCent; // "_ethUsdRateInCent"
    }

    /* Transfer out any accidentally sent ERC20 tokens */
    function transferAnyERC20Token(address tokenAddress, uint amount) onlyOwner returns (bool success) {

        return ERC20Interface(tokenAddress).transfer(owner, amount);
    }

    function stopICO() onlyOwner {

        isIcoRunning = false;
    }

    function startICO() onlyOwner {

        isIcoRunning = true;
    }

    function remainingTokensForSale() constant returns (uint) {
        
        return TOKEN_SUPPLY_MAINSALE_LIMIT.sub(shrToken.totalSupply());
    }

    function __callback(bytes32 myid, string result) {
        
        // Never use require right here. It won't work!
        if (msg.sender != oraclize_cbAddress()) throw;
        ethUsdRateInCent = parseInt(result, 2);
        
        if (isIcoRunning == true) {
            updateRate();
        } else {
            isUpdateRateRunning = false;
        }
    }

    function updateRate() payable {
        
        require(msg.sender == owner);

        if (oraclize_getPrice("URL") <= this.balance) {
            // Get rate with delay
            oraclize_query(ETH_USD_UPDATE_PERIOD, "URL", "json(https://api.gdax.com/products/ETH-USD/ticker).price");
            isUpdateRateRunning = true;
        } else {
            isUpdateRateRunning = false;
        }
    }
}
