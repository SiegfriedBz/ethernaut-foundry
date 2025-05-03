// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../src/MagicNum.sol";
import "forge-std/Script.sol";
import "forge-std/console.sol";

/**
 * !! RUNTIME OPCODES
 * => we want to return 0x2A (42) but we can only RETURN something from MEMORY
 * 1. STORE in MEMORY
 * PUSH1 0x2A value
 * PUSH1 0x00 offset
 * MSTORE => store at offset 0x00 the value 0x2A
 * !! NOTE : a "word" of 32 bytes is stored at offset 0x00
 * !! this 32 bytes translates to 42 in decimals
 * !! BUT the byte 0x2A is the 31th byte
 * !! TO READ IT FROM MEMORY (return),
 * !!   the MEMORY OFFSET TO GET IT is 0x1F in hex,
 * !!   which translates to 31 in decimals
 * !! 000000000000000000000000000000000000000000000000000000000000002a
 * 2. RETURN from MEMORY
 * PUSH1 0x01 size
 * PUSH1 0x1F offset
 * !! because 0x2A is at offset 0x1F
 * RETURN => return from memory at offset 0x1F something of size 0x01 : 1byte
 *
 * !! ===> RUNTIME OPCODES : 602A6000526001601FF3
 *                                      _______
 * NOTE
 * We also could do
 * PUSH1 0x2A value
 * PUSH1 0x00 offset
 * MSTORE => store at offset 0x00 the value 0x2A
 * 2. RETURN from MEMORY
 * PUSH1 0x20 size 32 bytes
 * PUSH1 0x00 offset
 * !! because the whole 32bytes 0x00....2A is at offset 0x00
 * RETURN => return from memory at offset 0x00 something of size 0x20 : 32bytes
 *
 * !! ===> RUNTIME OPCODES : 602A60005260206000F3
 *                                         _______
 */

/**
 * !! DEPLOYMENT CODE
 * PUSH10 602A6000526001601FF3 // push the 10 bytes of RUNTIME CODE
 * PUSH1 0x00
 * MSTORE => store at offset 0x00 the value 0x602A6000526001601FF3
 * PUSH1 0x20 size 32 bytes
 * PUSH1 0x00 offset
 * RETURN => return from memory at offset 0x00 something of size 0x20 : 32bytes === RUNTIME CODE PADDED WITH 0 on the left
 *
 *  *
 * !! ===> DEPLOYMENT CODE : 69602A6000526001601FF360005260206000F3
 */
contract SolverDeployer {
    MagicNum public magicNum;

    constructor(address _magicNumAddress) {
        magicNum = MagicNum(_magicNumAddress);

        bytes memory solverDeploymentBytecode = hex"69602A6000526001601FF360005260206000F3";

        address solverAddress;

        assembly {
            solverAddress := create(0, add(solverDeploymentBytecode, 0x20), mload(solverDeploymentBytecode))
        }

        magicNum.setSolver(solverAddress);
    }
}

contract MagicNumScript is Script {
    address constant ETHERNAUT_CONTRACT_ADDRESS = 0xaf20839a276F00e68cBaFA1A49826EAF7F577555;
    MagicNum public magicNum = MagicNum(ETHERNAUT_CONTRACT_ADDRESS);

    function run() external {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));

        new SolverDeployer(address(magicNum));

        vm.stopBroadcast();
    }
}
