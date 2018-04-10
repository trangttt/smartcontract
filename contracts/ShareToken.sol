pragma solidity ^0.4.21;

import "./oraclizeAPI_0.5.sol";
import "./Owned.sol";
import "./SafeMath.sol";
import "./ERC20Token.sol";

contract ShareToken is ERC20Token, Owned {

    using SafeMath for uint;

    string public constant name = "ShareToken";
    string public constant symbol = "SHR";
    uint8  public constant decimals = 2;

    address public icoContract;

    bool public transferPresaleEnabled = false;

    // Any token amount must be multiplied by this const to reflect decimals
    uint constant E2 = 10**2;

    mapping(address => bool) locked;

    uint public constant TOKEN_SUPPLY_AIRDROP_LIMIT  = 6666666667; // 66,666,666.67 tokens (0.066 billion)
    uint public constant TOKEN_SUPPLY_BOUNTY_LIMIT   = 33333333333; // 333,333,333.33 tokens (0.333 billion)

    uint public airDropTokenIssuedTotal;
    uint public bountyTokenIssuedTotal;

    uint public constant TOKEN_SUPPLY_SEED_LIMIT      = 500000000 * E2; // 500,000,000 tokens (0.5 billion)
    uint public constant TOKEN_SUPPLY_PRESALE_LIMIT   = 2500000000 * E2; // 2,500,000,000.00 tokens (2.5 billion)

    uint public seedAndPresaleTokenIssuedTotal;

    function ShareToken() public {

        totalTokenIssued = 0;
        airDropTokenIssuedTotal = 0;
        bountyTokenIssuedTotal = 0;
        seedAndPresaleTokenIssuedTotal = 0;
    }

    function totalSupply() constant returns (uint) {

        return (totalTokenIssued + seedAndPresaleTokenIssuedTotal + airDropTokenIssuedTotal + bountyTokenIssuedTotal);
    }

    function totalMainSaleTokenIssued() constant returns (uint) {

        return totalTokenIssued;
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

    function setIcoContract(address _icoContract) onlyOwner {
        
        if (_icoContract != address(0)) {

            icoContract = _icoContract;
        }
    }

    function sell(address buyer, uint tokens) returns (bool success) {
      
        require (tokens > 0);
        require (buyer != address(0));
        require (msg.sender == icoContract);

        // Register tokens issued to the buyer
        balances[buyer] = balances[buyer].add(tokens);

        // Update total amount of tokens issued
        totalTokenIssued = totalTokenIssued.add(tokens);

        // Lock the buyer
        locked[buyer] = true;

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

    function enableTransferPresale() onlyOwner {

        transferPresaleEnabled = true;   
    }

    function disableTransferPresale() onlyOwner {

        transferPresaleEnabled = false;   
    }

    function transferSeedToken(address _to, uint _amount) {

        require(transferPresaleEnabled);

        uint seedAndPresaleTokenLimit = TOKEN_SUPPLY_SEED_LIMIT + TOKEN_SUPPLY_PRESALE_LIMIT;
        require(seedAndPresaleTokenIssuedTotal < seedAndPresaleTokenLimit);

        uint remainingTokens = seedAndPresaleTokenLimit.sub(seedAndPresaleTokenIssuedTotal);
        require (_amount <= remainingTokens);

        // Register tokens to the receiver
        balances[_to] = balances[_to].add(_amount);

        // Update total amount of tokens issued
        seedAndPresaleTokenIssuedTotal = seedAndPresaleTokenIssuedTotal.add(_amount);

        // Do not lock the seed

        Transfer(address(0x0), _to, _amount);
    }

    function transferSeedTokenMany(address[] addrList, uint[] amountList) {

        require(addrList.length == amountList.length);

        for (uint i = 0; i < addrList.length; i++) {

            transferSeedToken(addrList[i], amountList[i]);
        }
    }
}
