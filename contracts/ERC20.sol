// SPDX-License-Identifier: MIT 
pragma solidity 0.8.28;

// import './IERC20.sol';

contract ERC20 {
    address public owner;
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approval(address indexed owner, address indexed spender, uint256 amount);

    error InvalidAmount();
    error InvalidAddress();
    error InsufficientAmount();

    constructor(string memory _name, string memory _symbol, uint8 _decimals) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        owner = msg.sender;
    }

    function _mint(address to, uint256 amount) internal {
        if(to == address(0)) revert InvalidAddress();
        if(amount <= 0) revert InvalidAmount();

        totalSupply += amount;
        balanceOf[to] += amount;

        emit Transfer(address(0), to, amount);
    }

    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }

    function transfer(address to, uint256 amount) external returns (bool) {
        if(to == address(0)) revert InvalidAddress();
        if(amount <= 0) revert InvalidAmount();
        if(balanceOf[msg.sender] < amount) revert InsufficientAmount();

        balanceOf[msg.sender] -= amount;
        balanceOf[to] += amount;

        emit Transfer(msg.sender, to, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) external returns (bool) {
        if(from == address(0)) revert InvalidAddress();
        if(to == address(0)) revert InvalidAddress();
        if(amount <= 0) revert InvalidAmount();
        if(balanceOf[from] < amount) revert InsufficientAmount();

        allowance[from][msg.sender] -= amount;
        balanceOf[from] -= amount;
        balanceOf[to] += amount;

        emit Transfer(from, to, amount);
        return true;
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        if(spender == address(0)) revert InvalidAddress();

        allowance[msg.sender][spender] = amount;
        
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function _burn(address from, uint256 amount) internal {
        if(from == address(0)) revert InvalidAddress();
        if(balanceOf[from] < amount) revert InsufficientAmount();

        totalSupply -= amount;
        balanceOf[from] -= amount;

        emit Transfer(from, address(0), amount);
    }

    function burn(address from, uint256 amount) external {
        _burn(from, amount);
    }
}