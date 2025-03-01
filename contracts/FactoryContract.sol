// SPDX-License-Identifier: MIT 
pragma solidity 0.8.28;

import "./PiggyBank.sol";

contract FactoryContract {

    mapping(address => address[]) public kolos;
    mapping(address => bool) public kolosStatus;

    event PiggyBankCreated(address indexed owner, address piggyBankAddress, uint256 duration);

    error ZeroDuration();
    error DeploymentFailed();
    error InvalidAddress();
    error InvalidAmount();
    error NoKoloForYou();
    error KoloNotFound();
    error KoloDestroyed();
    error KoloAlreadyDestroyed();

    function createPiggyBank(uint256 _duration, bytes32 _salt) external returns (address) {
        if (_duration <= 0) revert ZeroDuration();

        address piggyBankAddress = address(new PiggyBank{salt: _salt}(_duration));

        if (piggyBankAddress == address(0)) revert DeploymentFailed();

        kolos[msg.sender].push(piggyBankAddress);
        kolosStatus[piggyBankAddress] = true;

        emit PiggyBankCreated(msg.sender, piggyBankAddress, _duration);

        return piggyBankAddress;
    }

    function computePiggyBankAddress(uint256 _duration, bytes32 _salt) external view returns (address) {
        bytes32 bytecodeHash = keccak256(abi.encodePacked(type(PiggyBank).creationCode, abi.encode(_duration)));

        return address(uint160(uint256(keccak256(abi.encodePacked(bytes1(0xff), address(this), _salt, bytecodeHash)))));
    }

    function tokenDeposit(address _koloAddress, address _tokenAddress, uint256 _amount) external returns (bool) {
        if(_koloAddress == address(0)) revert InvalidAddress();
        if(_tokenAddress == address(0)) revert InvalidAddress();
        if(_amount <= 0) revert InvalidAmount();

        checkKolosState(_koloAddress);

        PiggyBank(_koloAddress).saveToken(_koloAddress, _tokenAddress, _amount);

        return true;
    }

    function koloDestruction(address _koloAddress, address _tokenAddress) external returns (bool) {
        if(_koloAddress == address(0)) revert InvalidAddress();
        if(_tokenAddress == address(0)) revert InvalidAddress();

        checkKolosState(_koloAddress);

        PiggyBank(_koloAddress).withdrawToken(_koloAddress, _tokenAddress);

        return true;
    }

    function checkKolosState(address _koloAddress) private view returns (bool) {
        if(_koloAddress == address(0)) revert InvalidAddress();

        address[] memory kolosList = kolos[msg.sender];

        if(kolosList.length == 0) revert NoKoloForYou();

        bool isAvailable = false;

        for(uint256 i = 0; i < kolosList.length; i++) {
            if(kolosList[i] == _koloAddress) {
                isAvailable = true;
                return isAvailable;
            }
        }

        if(isAvailable == false) revert KoloNotFound();

        if(isAvailable == true) {
            if(kolosStatus[_koloAddress] == false) revert KoloAlreadyDestroyed();
        }

        return true;
    }
}