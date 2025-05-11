// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../src/PuzzleWallet.sol";
import "forge-std/Script.sol";
import "forge-std/console.sol";

contract PuzzleWalletScript is Script {
    address constant ETHERNAUT_CONTRACT_ADDRESS = 0x2f3dB9d117Aa683dCF8fFfDC7C09849EcEd8d1C6;
    PuzzleWallet public puzzleWallet = PuzzleWallet(ETHERNAUT_CONTRACT_ADDRESS);

    function run() external {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));

        vm.stopBroadcast();
    }
}
