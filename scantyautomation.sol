// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@chainlink/contracts/src/v0.8/AutomationBase.sol";
import "./scanty.sol";
import "./scantyrng.sol";

contract ScantyRebaseTokenAutomation is AutomationBase {
    scanty public rebaseToken;
    scantyrng public vrf;

    // Constructor
    constructor(address rebaseTokenAddress, address vrfAddress) {
        rebaseToken = scantytoken(rebaseTokenAddress);
        vrf = scantyrng(vrfAddress);
    }

    // Perform Upkeep
    function performUpkeep(bytes calldata /* data */) external override {
        vrf.getRandomNumber();
    }
}
