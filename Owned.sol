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