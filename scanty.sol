// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@chainlink/contracts/src/v0.8/interfaces/KeeperCompatibleInterface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";

contract Scanty is ERC20, Ownable, KeeperCompatibleInterface, VRFConsumerBase {
    uint256 public lastRebaseTime;
    uint256 public rebaseCooldown;
    uint256 public randomResult;

    bytes32 internal keyHash;
    uint256 internal fee;

    constructor() 
        ERC20("Scanty", "SCNT") 
        VRFConsumerBase(
            0xf0d54349aDdcf704F77AE15b96510dEA15cb7952,  // VRF Coordinator
            0x514910771AF9Ca656af840dff83E8264EcF986CA   // LINK Token
        )
    {
        _mint(msg.sender, 1 * 10 ** decimals());
        lastRebaseTime = block.timestamp;
        rebaseCooldown = 1 days;

        keyHash = 0xced103054e349b8dfb51352f0f8fa9b5d20dde3d06f9f43cb2b85bc64b238205;
        fee = 0.1 * 10 ** 18;  // 0.1 LINK

	grantRole(ROLE_AUTOMATOR, address(scantyrng));
    }

    function fulfillRandomness(bytes32 requestId, uint256 randomness) internal override {
        randomResult = randomness;
        rebase();
    }

    function checkUpkeep(bytes calldata checkData) external override returns (bool upkeepNeeded, bytes memory performData) {
        upkeepNeeded = (block.timestamp - lastRebaseTime >= rebaseCooldown);

        if (upkeepNeeded) {
            performData = checkData;
        }
    }

    function performUpkeep(bytes calldata performData) external override {
        require(block.timestamp - lastRebaseTime >= rebaseCooldown, "Rebase not allowed yet");
        
        // Request randomness from Chainlink VRF
        require(LINK.balanceOf(address(this)) >= fee, "Not enough LINK to pay fee");
        requestRandomness(keyHash, fee);

        // Update lastRebaseTime
        lastRebaseTime = block.timestamp;
    }

    function rebase() internal {
        uint256 newSupply = totalSupply() + (totalSupply() * randomResult) / 10 ** 18;
        _mint(owner(), newSupply - totalSupply());
    }
}
