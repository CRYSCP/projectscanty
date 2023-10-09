// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract scantyrng is VRFConsumerBase, Ownable {
    // Chainlink VRF state variables
    bytes32 private keyHash;
    uint256 private fee;
    uint256 public randomResult;

    // Event
    event RandomNumberGenerated(uint256 randomNumber);

    // Constructor
    constructor(
        address vrfCoordinator, // VRF Coordinator address
        address linkToken,      // LINK token address
        address initialOwner,   // Initial owner address
        bytes32 keyHash_, 
        uint256 fee_
    ) 
        VRFConsumerBase(vrfCoordinator, linkToken) // Initialize VRFConsumerBase
        Ownable(initialOwner)  // Initialize Ownable
    {
        keyHash = keyHash_;
        fee = fee_;
    }

    // Request random number from Chainlink VRF
    function getRandomNumber() external onlyOwner returns (bytes32 requestId) {
        require(LINK.balanceOf(address(this)) >= fee, "Insufficient LINK tokens");
        return requestRandomness(keyHash, fee);
    }

    // Callback function to handle random number
    function fulfillRandomness(bytes32 /* requestId */, uint256 randomness) internal override {
    randomResult = randomness;
    emit RandomNumberGenerated(randomness);
    }

    // Set keyHash (for example purposes, normally you wouldn't change this often)
    function setKeyHash(bytes32 newKeyHash) external onlyOwner {
        keyHash = newKeyHash;
    }

    // Set fee (for example purposes, normally you wouldn't change this often)
    function setFee(uint256 newFee) external onlyOwner {
        fee = newFee;
    }
}
