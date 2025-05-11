// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../src/Preservation.sol";
import "forge-std/Script.sol";
import "forge-std/console.sol";

contract PreservationScript is Script {
    address constant ETHERNAUT_CONTRACT_ADDRESS = 0x87005037050210260583Fa9e08F9F432FE9952C9;
    Preservation public preservation = Preservation(ETHERNAUT_CONTRACT_ADDRESS);

    function run() external {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));

        vm.stopBroadcast();
    }
}
