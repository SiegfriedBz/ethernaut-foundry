// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../src/Motorbike.sol";
import "forge-std/Script.sol";
import "forge-std/console.sol";

contract PuzzleWalletScript is Script {
    address constant ETHERNAUT_CONTRACT_ADDRESS = 0xDF70C100492B487351A820c171F80f9b0c2Bbd7b;
    Motorbike public bike = Motorbike(payable(ETHERNAUT_CONTRACT_ADDRESS));

    // address PLAYER = address(uint160(uint256(vm.envUint("MY_ADDRESS"))));

    function run() external {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));

        vm.stopBroadcast();
    }
}
