// SPDX-License-Identifier: MIT 
pragma solidity 0.8.28;

import "./ERC20.sol";

contract PiggyBank {

    address public owner;
    uint256 public duration;
    mapping(address => bool) public tokens;

    error UnAuthorize(address user); 
    error InvalidAddress(address givenAddress); 
    error InvaldAmount(uint256 amount);
    error InsufficientAmount(uint256 amount);
    error UnsupportedToken();

    event Transfer(address _owner, address _bankAddress, uint256 _amount);
    event Receive(address _owner, address _bankAddress, uint256 _amount);

    modifier OnlyOwner() {
        if(owner != msg.sender) revert UnAuthorize(msg.sender);
        _;
    }

    constructor(uint256 _duration) {
        owner = msg.sender;
        duration = _duration;
        // tokens[0x4b61Df4dA7c04877113e772CeA1baE79Cf666926] = true;
        // tokens[0x1D4112A50DbED80743b098442D990AF293B45817] = true;
        // tokens[0xB0b2C79E89bDDaA13932aAF2006c88757D456e49] = true;
    }

    function saveToken(address _bankAddress, address _tokenAddress, uint256 _amount) external OnlyOwner returns (bool) {
        if(_bankAddress == address(0)) revert InvalidAddress(_bankAddress);
        if(_tokenAddress == address(0)) revert InvalidAddress(_tokenAddress);
        if(_amount <= 0) revert InvaldAmount(_amount);
        if(tokens[_tokenAddress] != true) revert UnsupportedToken();
        if(ERC20(_tokenAddress).balanceOf(owner) < _amount) revert InsufficientAmount(_amount);

        ERC20(_tokenAddress).transferFrom(owner, _bankAddress, _amount);

        emit Transfer(owner, _bankAddress, _amount);

        return true;
    }

    function withdrawToken(address _bankAddress, address _tokenAddress) external OnlyOwner returns (bool) {
        if(_bankAddress == address(0)) revert InvalidAddress(_bankAddress);
        if(_tokenAddress == address(0)) revert InvalidAddress(_tokenAddress);

        uint256 balance = ERC20(_tokenAddress).balanceOf(owner);

        if(duration > block.timestamp) {
            uint256 amount = (balance * 15) / 100;
            ERC20(_tokenAddress).transfer(owner, amount);
            emit Receive(owner, _bankAddress, amount);
        } else {
            ERC20(_tokenAddress).transfer(owner, balance);
            emit Receive(owner, _bankAddress, balance);
        }

        return true;
    }
}