pragma solidity ^0.4.21;

import "./ERC20Interface.sol";
import "./SafeMath.sol";

contract ERC20Token is ERC20Interface {

    using SafeMath for uint;

    // Total amount of tokens issued
    uint internal totalTokenIssued;

    mapping(address => uint) balances;
    mapping(address => mapping (address => uint)) allowed;

    function totalSupply() public constant returns (uint) {
        return totalTokenIssued;
    }

    /* Get the account balance for an address */
    function balanceOf(address _owner) public constant returns (uint balance) {
        return balances[_owner];
    }

    /* Check whether an address is a contract address */
    function isContract(address addr) internal view returns (bool) {
        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }


    /* Transfer the balance from owner's account to another account */
    function transfer(address _to, uint _amount) public returns (bool success) {
        // amount sent cannot exceed balance
        require(balances[msg.sender] >= _amount);

        // Do not allow to transfer token to contract address to avoid tokens getting stuck
        require(isContract(_to) == false);

        // update balances
        balances[msg.sender] = balances[msg.sender].sub(_amount);
        balances[_to]        = balances[_to].add(_amount);

        // log event
        emit Transfer(msg.sender, _to, _amount);
        return true;
    }
    

    /* Allow _spender to withdraw from your account up to _amount */
    function approve(address _spender, uint _amount) public returns (bool success) {
        // approval amount cannot exceed the balance
        require(balances[msg.sender] >= _amount);

        // Only allow contract address
        require(isContract(_spender));

        // update allowed amount
        allowed[msg.sender][_spender] = _amount;

        // log event
        emit Approval(msg.sender, _spender, _amount);
        return true;
    }

    /* Spender of tokens transfers tokens from the owner's balance */
    /* Must be pre-approved by owner */
    function transferFrom(address _from, address _to, uint _amount) public returns (bool success) {
        // balance checks
        require(balances[_from] >= _amount);
        require(allowed[_from][msg.sender] >= _amount);

        // update balances and allowed amount
        balances[_from]            = balances[_from].sub(_amount);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_amount);
        balances[_to]              = balances[_to].add(_amount);

        // log event
        emit Transfer(_from, _to, _amount);
        return true;
    }

    /* Returns the amount of tokens approved by the owner */
    /* that can be transferred by spender */
    function allowance(address _owner, address _spender) public constant returns (uint remaining) {
        return allowed[_owner][_spender];
    }
}
