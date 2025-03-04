// SPDX-License-Identifier: MIT 
pragma solidity 0.8.28;

import "./ERC20.sol";

contract PiggyBank {

    address public owner;
    address public manager;
    uint256 public duration;
    mapping(address => bool) public tokens;

    error UnAuthorize(address user); 
    error InvalidAddress(address givenAddress); 
    error InvaldAmount(uint256 amount);
    error InsufficientAmount(uint256 amount);
    error UnsupportedToken();

    event Transfer(address _owner, address _bankAddress, uint256 _amount);
    event Receive(address _owner, address _bankAddress, uint256 _amount);

    modifier OnlyManager() {
        if(manager != msg.sender) revert UnAuthorize(msg.sender);
        _;
    }

    constructor(uint256 _duration, address _owner) {
        manager = msg.sender;
        owner = _owner;
        duration = _duration;
    }

    function allowTokens(address _tokenAddress) external returns (bool) {
        if(_tokenAddress == address(0)) revert InvalidAddress(_tokenAddress);

        tokens[_tokenAddress] = true;

        return true;
    }

    function saveToken(address _bankAddress, address _tokenAddress, uint256 _amount) external OnlyManager returns (bool) {
        if(_bankAddress == address(0)) revert InvalidAddress(_bankAddress);
        if(_tokenAddress == address(0)) revert InvalidAddress(_tokenAddress);
        if(_amount <= 0) revert InvaldAmount(_amount);
        if(tokens[_tokenAddress] != true) revert UnsupportedToken();
        if(ERC20(_tokenAddress).balanceOf(owner) < _amount) revert InsufficientAmount(_amount);

        ERC20(_tokenAddress).transferFrom(owner, _bankAddress, _amount);

        emit Transfer(owner, _bankAddress, _amount);

        return true;
    }

    function withdrawToken(address _bankAddress, address _tokenAddress) external OnlyManager returns (bool) {
        if(_bankAddress == address(0)) revert InvalidAddress(_bankAddress);
        if(_tokenAddress == address(0)) revert InvalidAddress(_tokenAddress);

        uint256 balance = ERC20(_tokenAddress).balanceOf(_bankAddress);

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
