// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../src/Delegation.sol";
import "forge-std/Script.sol";
import "forge-std/console.sol";

contract MagicNumScript is Script {
    address constant ETHERNAUT_CONTRACT_ADDRESS = 0x29Ab8387a28A684617a365d0738ef106BCf6b5B6;
    Delegation public delegation = Delegation(ETHERNAUT_CONTRACT_ADDRESS);

    function run() external {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));

        vm.stopBroadcast();
    }
}
