
/** 
 *  SourceUnit: c:\Users\memunat\Documents\GitHub\solidity-by-example\ERC20 Token\contracts\ERC20Token.sol
*/

////// SPDX-License-Identifier-FLATTEN-SUPPRESS-WARNING: MIT
pragma solidity 0.8.0;

interface ERC20Interface {
    /// @notice send `_value` token to `_to` from `msg.sender`
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return success Whether the transfer was successful or not
    function transfer(address to, uint tokens) public returns (bool success);
    /// @notice send `_value` token to `_to` from `_from` on the condition it is approved by `_from`
    /// @param _from The address of the sender
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return success Whether the transfer was successful or not
    function transferFrom(address from, address to, uint tokens) public returns (bool success);

    /// @param _owner The address from which the balance will be retrieved
    /// @return balance the balance
    function balanceOf(address tokenOwner) public view returns (uint256 balance);
    /// @notice `msg.sender` approves `_addr` to spend `_value` tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @param _value The amount of wei to be approved for transfer
    /// @return success Whether the approval was successful or not
    function approve(address spender, uint tokens) public returns (bool success);
    /// @param _owner The address of the account owning tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @return remaining Amount of remaining tokens allowed to spent
    function allowance(address tokenOwner, address spender) public view returns (uint256 remaining);
    function totalSupply() public view returns (uint);

    event Transfer(address indexed from, address indexed to, uint tokens);  //this is triggered when tokens are trasfered either from 
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);   //this is triggered on any succesful call to approve()
}

contract ERC20Token is ERC20Interface {
    string public name; //returns the name of the token, it is optional
    string public symbol;   //this returns the symbol/ticker of the token
    uint8 public decimals;  //this returns the number of decimals the token uses 
    uint256 public _totalSupply;    //reyruens the total amount of tokens
    mapping(address => uint) public balances;   //this tracks token addresses of each address
    mapping(address => mapping(address => uint)) public allowed;    //this tracks the token amount an address has approved another address to spend
    
    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals,
        uint256 _initialSupply)
        public {
            name = _name;
            symbol = _symbol;
            decimals = _decimals;
            _totalSupply = _initialSupply;
            balances[msg.sender] = _totalSupply;    //initializes the balances of the token to the creator of the contract
        }
        
    function transfer(address to, uint value) public returns(bool) {
        require(balances[msg.sender] >= value, 'token balance too low');
        balances[msg.sender] -= value;
        balances[to] += value;
        emit Transfer(msg.sender, to, value);
        return true;
    }
    
    function transferFrom(address from, address to, uint value) public returns(bool) {
        uint allowance = allowed[from][msg.sender];
        require(allowance >= value, 'allowance too low');
        require(balances[from] >= value, 'token balance too low');
        allowed[from][msg.sender] -= value;
        balances[from] -= value;
        balances[to] += value;
        emit Transfer(from, to, value);
        return true;
    }

    function approve(address spender, uint value) public returns(bool) {
        allowed[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }
    
    function allowance(address owner, address spender) public view returns(uint) {
        return allowed[owner][spender];
    }
    
    function balanceOf(address owner) public view returns(uint) {
        return balances[owner];
    }

    function totalSupply() public view returns (uint) {
        return _totalSupply;
    }
}

