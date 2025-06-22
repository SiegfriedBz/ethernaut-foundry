// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../src/DexTwo.sol";
import "forge-std/Script.sol";
import "forge-std/console.sol";

contract DexTwoScript is Script {
    address constant ETHERNAUT_CONTRACT_ADDRESS = 0x0d4C8c2C5B02aA8a120c602CF2ebb822BF55213f;
    DexTwo public dex = DexTwo(payable(ETHERNAUT_CONTRACT_ADDRESS));

    address token1Address;
    address token2Address;
    SwappableToken token1;
    SwappableToken token2;

    uint256 playerToken1Bal;
    uint256 playerToken2Bal;
    uint256 dexToken1Bal;
    uint256 dexToken2Bal;

    address PLAYER = vm.envAddress("MY_ADDRESS");

    function run() external {
        token1Address = dex.token1();
        token2Address = dex.token2();

        token1 = SwappableToken(token1Address);
        token2 = SwappableToken(token2Address);

        // // dex token 1 & 2 balance
        // dexToken1Bal = token1.balanceOf(address(dex));
        // dexToken2Bal = token2.balanceOf(address(dex));

        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));

        // 1. approve dex for max tokens (1 & 2)
        uint256 max = type(uint256).max;
        dex.approve(address(dex), max);

        // 2

        // 3 remove dex approval for tokens (1 & 2)
        dex.approve(address(dex), 0);

        vm.stopBroadcast();

        playerToken1Bal = token1.balanceOf(PLAYER);
        playerToken2Bal = token2.balanceOf(PLAYER);
        console.log("playerToken1Bal", playerToken1Bal);
        console.log("playerToken2Bal", playerToken2Bal);

        dexToken1Bal = token1.balanceOf(address(dex));
        dexToken2Bal = token2.balanceOf(address(dex));
        console.log("dexToken1Bal", dexToken1Bal);
        console.log("dexToken2Bal", dexToken2Bal);
    }

    // make sure the DEX has enough of the token we are asking for
    function _maxAmountToSwap(address _from, uint256 _amountFrom) private view returns (uint256) {
        /**
         * swap tokenA for tokenB
         * amountTokenB = amountTokenA * DexBalTokenB / DexBalTokenA
         * amountTokenB must be <= DexBalTokenB
         * ===> amountTokenA / DexBalTokenA <= 1
         * ======> amountTokenA <= DexBalTokenA
         */
        uint256 dexBalFrom = SwappableToken(_from).balanceOf(address(dex));

        return _amountFrom <= dexBalFrom ? _amountFrom : dexBalFrom;
    }
}
