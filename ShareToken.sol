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

contract ERC20Token is ERC20Interface, Owned {

    using SafeMath for uint;

    // Total amount of tokens issued
    uint totalTokenIssued;

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

contract ShareToken is ERC20Token, WhitelistedCrowdsale, usingOraclize {

    string public constant name     = "ShareToken";
    string public constant symbol   = "SHR";
    uint8  public constant decimals = 2;
    uint constant E2 = 10**2; // any token amount must be multiplied by this const to reflect decimals

    bool public isIcoRunning = true;
    bool public isUpdateRateRunning = true;

    uint public tokenPriceInCent = 2; // cent or $0.02
    uint public ethUsdRateInCent = 0;// cent

    uint constant TOKEN_SUPPLY_TOTAL_LIMIT    = 1400000000 * E2; // (1.4 billion)
    uint public constant TOKEN_SUPPLY_MAINSALE_LIMIT = 1000000000 * E2; // 1,000,000,000 tokens (1 billion)
    uint public constant TOKEN_SUPPLY_AIRDROP_LIMIT  = 6666666667; // 66,666,666.67 tokens (0.066 billion)
    uint public constant TOKEN_SUPPLY_BOUNTY_LIMIT   = 33333333333; // 333,333,333.33 tokens (0.333 billion)

    uint public airDropTokenIssuedTotal    = 0;
    uint public bountyTokenIssuedTotal     = 0;

    uint public constant ETH_USD_UPDATE_PERIOD = 86400; // 24 * 60 * 60 (for every 24 hours) 

    mapping(address => uint) airDropTokenIssuedList;
    mapping(address => uint) bountyTokenIssuedList;

    mapping(address => bool) locked;

    // Must supply the ETH/USD rate (in cent) upon token creation
    function ShareToken(uint _ethUsdRateInCent) payable {

        uint tokenSupplyLimit = TOKEN_SUPPLY_MAINSALE_LIMIT + TOKEN_SUPPLY_AIRDROP_LIMIT + TOKEN_SUPPLY_BOUNTY_LIMIT; 
        require( tokenSupplyLimit == TOKEN_SUPPLY_TOTAL_LIMIT );
        
        require(_ethUsdRateInCent > 0);

        totalTokenIssued = 0;
        ethUsdRateInCent = _ethUsdRateInCent;

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

        // If the allocated tokens exceed the limit, must refund to user
        if (totalTokenIssued.add(tokens) > TOKEN_SUPPLY_MAINSALE_LIMIT) {

            uint tokensAvailable = TOKEN_SUPPLY_MAINSALE_LIMIT - totalTokenIssued;
            uint tokensToRefund = tokens - tokensAvailable;
            uint ethToRefundInWei = tokensToRefund.div(tokenPriceInCent).div(ethUsdRateInCent).mul(10**18);
            
            // Refund
            msg.sender.transfer(ethToRefundInWei);

            // Update actual tokens to be sold
            tokens = tokensAvailable;

            // Stop ICO
            isIcoRunning = false;
        }

        // Allocate tokens to the buyer
        balances[msg.sender] = balances[msg.sender].add(tokens);

        // Update total amount of tokens issued
        totalTokenIssued = totalTokenIssued.add(tokens);

        // Lock the buyer
        locked[msg.sender] = true;

        Transfer(address(0x0), msg.sender, tokens);
    }

    function withdrawToOwner() payable {

        require(msg.sender == owner);
        owner.transfer(this.balance);
    }

    function withdrawTo(address _to) payable {

        require(msg.sender == owner);
        _to.transfer(this.balance);
    }

    function unLock(address _participant) onlyOwner {

        locked[_participant] = false;
    }

    function unLockMultiple(address[] _participants) onlyOwner {

        for (uint i = 0; i < _participants.length; i++) {
            locked[_participants[i]] = false;
        }
    }

    function unLockAllWhitelist() onlyOwner {

        require (isIcoRunning == false);

        for (uint i = 0; i < whitelistAddresses.length; i++) {
            locked[whitelistAddresses[i]] = false;
        }
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

    function rewardAirdrop(address _to, uint _amount) onlyOwner {

        require(isIcoRunning == true);
        require(airDropTokenIssuedTotal < TOKEN_SUPPLY_AIRDROP_LIMIT);

        uint remainingTokens = TOKEN_SUPPLY_AIRDROP_LIMIT.sub(airDropTokenIssuedTotal);
        if (_amount > remainingTokens) {
            _amount = remainingTokens;
        }

        // Allocate tokens to the receiver
        balances[_to] = balances[_to].add(_amount);

        // Update total amount of tokens issued
        airDropTokenIssuedTotal = airDropTokenIssuedTotal.add(_amount);

        // Lock the receiver
        locked[_to] = true;

        Transfer(address(0x0), _to, _amount);
    }

    function rewardBounty(address _to, uint _amount) onlyOwner {

        require(isIcoRunning == true);
        require(bountyTokenIssuedTotal < TOKEN_SUPPLY_BOUNTY_LIMIT);

        uint remainingTokens = TOKEN_SUPPLY_BOUNTY_LIMIT.sub(bountyTokenIssuedTotal);
        if (_amount > remainingTokens) {
            _amount = remainingTokens;
        }

        // Allocate tokens to the receiver
        balances[_to] = balances[_to].add(_amount);

        // Update total amount of tokens issued
        bountyTokenIssuedTotal = bountyTokenIssuedTotal.add(_amount);

        // Lock the receiver
        locked[_to] = true;

        Transfer(address(0x0), _to, _amount);
    }

    /* Override "transfer" (ERC20) */
    function transfer(address _to, uint _amount) returns (bool success) {

        require( locked[msg.sender] == false );    
        require( locked[_to] == false );
        
        return super.transfer(_to, _amount);
    }

    /* Override "transferFrom" (ERC20) */
    function transferFrom(address _from, address _to, uint _amount) returns (bool success) {
        
        require( locked[_from] == false );
        require( locked[_to] == false );

        return super.transferFrom(_from, _to, _amount);
    }

    function remainingTokensForSale() constant returns (uint) {
        
        return TOKEN_SUPPLY_MAINSALE_LIMIT.sub(totalTokenIssued);
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
        
        if (oraclize_getPrice("URL") <= this.balance) {
            // Get rate with delay
            oraclize_query(ETH_USD_UPDATE_PERIOD, "URL", "json(https://api.gdax.com/products/ETH-USD/ticker).price");
            isUpdateRateRunning = true;
        } else {
            isUpdateRateRunning = false;
        }
    }
}
