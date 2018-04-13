pragma solidity ^0.4.21;

import "./oraclizeAPI_0.5.sol";
import "./Owned.sol";
import "./SafeMath.sol";
import "./ERC20Token.sol";
import "./WhiteListManager.sol";

contract ShareToken is ERC20Token, WhiteListManager {

    using SafeMath for uint;

    event Amount(uint amount);

    string public constant name = "ShareToken";
    string public constant symbol = "SHR";
    uint8  public constant decimals = 2;

    address public icoContract;

    // Any token amount must be multiplied by this const to reflect decimals
    uint constant E2 = 10**2;

    mapping(address => bool) public rewardTokenLocked;
    bool public mainSaleTokenLocked = true;

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
        mainSaleTokenLocked = true;
    }

    function unlockMainSaleToken() public onlyOwner {

        mainSaleTokenLocked = false;
    }

    function lockMainSaleToken() public onlyOwner {

        mainSaleTokenLocked = true;
    }

    function unlockRewardToken(address addr) public onlyOwner {

        require(addr != address(0));
        rewardTokenLocked[addr] = false;
    }

    function unlockRewardTokenMany(address[] addrList) public onlyOwner {

        for (uint i = 0; i < addrList.length; i++) {

            unlockRewardToken(addrList[i]);
        }
    }

    function lockRewardToken(address addr) public onlyOwner {

        require(addr != address(0));
        rewardTokenLocked[addr] = true;
    }

    function lockRewardTokenMany(address[] addrList) public onlyOwner {

        for (uint i = 0; i < addrList.length; i++) {

            lockRewardToken(addrList[i]);
        }
    }

    // Check if a given address is locked. The address can be in the whitelist or in the reward
    function isLocked(address addr) public returns (bool) {

        // Main sale is running, any addr is locked
        if (mainSaleTokenLocked) {
            return true;
        } else {

            // Main sale is ended and thus any whitelist addr is unlocked
            if (isWhitelisted(addr)) {
                return false;
            } else {
                // If the addr is in the reward, it must be checked if locked
                // If the addr is not in the reward, it is considered unlocked
                return rewardTokenLocked[addr];
            }
        }
    }

    function totalSupply() public view returns (uint) {

        return (totalTokenIssued + seedAndPresaleTokenIssuedTotal + airDropTokenIssuedTotal + bountyTokenIssuedTotal);
    }

    function totalMainSaleTokenIssued() public view returns (uint) {

        return totalTokenIssued;
    }

    function transfer(address _to, uint _amount) public returns (bool success) {

        require(isLocked(msg.sender) == false);    
        require(isLocked(_to) == false);
        
        return super.transfer(_to, _amount);
    }

    function transferFrom(address _from, address _to, uint _amount) public returns (bool success) {
        
        require(isLocked(_from) == false);
        require(isLocked(_to) == false);

        return super.transferFrom(_from, _to, _amount);
    }

    function setIcoContract(address _icoContract) public onlyOwner {
        if (_icoContract != address(0)) {

            icoContract = _icoContract;
        }
    }

    function sell(address buyer, uint tokens) public returns (bool success) {
      
        require (tokens > 0);
        require (buyer != address(0));
        require (msg.sender == icoContract);

        // Register tokens issued to the buyer
        balances[buyer] = balances[buyer].add(tokens);

        // Update total amount of tokens issued
        totalTokenIssued = totalTokenIssued.add(tokens);

        emit Transfer(address(0x0), buyer, tokens);

        return true;
    }

    function rewardAirdrop(address _to, uint _amount) public onlyOwner {

        // this check also ascertains _amount is positive
        require(_amount <= TOKEN_SUPPLY_AIRDROP_LIMIT);

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
        rewardTokenLocked[_to] = true;

        emit Transfer(address(0x0), _to, _amount);
    }

    function rewardBounty(address _to, uint _amount) public onlyOwner {

        // this check also ascertains _amount is positive
        require(_amount <= TOKEN_SUPPLY_BOUNTY_LIMIT);

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
        rewardTokenLocked[_to] = true;

        emit Transfer(address(0x0), _to, _amount);
    }

    function handlePresaleToken(address _to, uint _amount) public onlyOwner {

        require(_amount <= TOKEN_SUPPLY_SEED_LIMIT + TOKEN_SUPPLY_PRESALE_LIMIT);
        _amount = _amount.mul(E2);

        uint seedAndPresaleTokenLimit = TOKEN_SUPPLY_SEED_LIMIT + TOKEN_SUPPLY_PRESALE_LIMIT;
        require(seedAndPresaleTokenIssuedTotal < seedAndPresaleTokenLimit);

        uint remainingTokens = seedAndPresaleTokenLimit.sub(seedAndPresaleTokenIssuedTotal);
        require (_amount <= remainingTokens);

        // Register tokens to the receiver
        balances[_to] = balances[_to].add(_amount);

        // Update total amount of tokens issued
        seedAndPresaleTokenIssuedTotal = seedAndPresaleTokenIssuedTotal.add(_amount);

        emit Transfer(address(0x0), _to, _amount);

        // Also add to whitelist
        set(_to);
    }

    function handlePresaleTokenMany(address[] addrList, uint[] amountList) public onlyOwner {

        require(addrList.length == amountList.length);

        for (uint i = 0; i < addrList.length; i++) {

            handlePresaleToken(addrList[i], amountList[i]);
        }
    }
}
