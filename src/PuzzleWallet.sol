// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;

/**
 * !! @notice added to adapt Eternaut dependencies
 * import "../helpers/UpgradeableProxy-08.sol"; // Eternaut dependency
 */
import "./UpgradeableProxy.sol";

/**
 * Nowadays, paying for DeFi operations is impossible, fact.
 *
 * A group of friends discovered how to slightly decrease the cost of performing multiple transactions by batching them in one transaction, so they developed a smart contract for doing this.
 *
 * They needed this contract to be upgradeable in case the code contained a bug, and they also wanted to prevent people from outside the group from using it. To do so, they voted and assigned two people with special roles in the system:
 * - The admin, which has the power of updating the logic of the smart contract.
 * - The owner, which controls the whitelist of addresses allowed to use the contract. The contracts were deployed, and the group was whitelisted. Everyone cheered for their accomplishments against evil miners.
 *
 * Little did they know, their lunch money was at risk…
 *
 *   You'll need to hijack this wallet to become the admin of the proxy.
 *
 *   Things that might help:
 *
 * Understanding how delegatecall works and how msg.sender and msg.value behaves when performing one.
 * Knowing about proxy patterns and the way they handle storage variables.
 */
contract PuzzleProxy is UpgradeableProxy {
    address public pendingAdmin; // slot 0
    address public admin; // slot 1

    constructor(address _admin, address _implementation, bytes memory _initData)
        UpgradeableProxy(_implementation, _initData)
    {
        admin = _admin;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "Caller is not the admin");
        _;
    }

    function proposeNewAdmin(address _newAdmin) external {
        pendingAdmin = _newAdmin;
    }

    function approveNewAdmin(address _expectedAdmin) external onlyAdmin {
        require(pendingAdmin == _expectedAdmin, "Expected new admin by the current admin is not the pending admin");
        admin = pendingAdmin;
    }

    function upgradeTo(address _newImplementation) external onlyAdmin {
        _upgradeTo(_newImplementation);
    }
}

contract PuzzleWallet {
    address public owner; // slot 0
    uint256 public maxBalance; // slot 1
    mapping(address => bool) public whitelisted;
    mapping(address => uint256) public balances;

    function init(uint256 _maxBalance) public {
        require(maxBalance == 0, "Already initialized");
        maxBalance = _maxBalance;
        owner = msg.sender;
    }

    modifier onlyWhitelisted() {
        require(whitelisted[msg.sender], "Not whitelisted");
        _;
    }

    /**
     * Allows a whitelisted user to set a new max balance,
     * but only when the contract's ETH balance is zero.
     *
     * => When used via delegatecall from the proxy, this function
     * updates storage slot 1 (maxBalance), which overlaps with
     * the `admin` variable in the proxy contract.
     * This enables an attacker to overwrite the proxy admin.
     */
    function setMaxBalance(uint256 _maxBalance) external onlyWhitelisted {
        require(address(this).balance == 0, "Contract balance is not 0");
        maxBalance = _maxBalance;
    }

    /**
     * Adds an address to the whitelist.
     *
     * Only callable by the `owner`.
     * When used via delegatecall through the proxy,
     * the `owner` variable (slot 0) overlaps with
     * `pendingAdmin` in the proxy.
     * If attacker sets pendingAdmin to its
     * address, and executes this function, he can whitelist himself.
     */
    function addToWhitelist(address addr) external {
        require(msg.sender == owner, "Not the owner");
        whitelisted[addr] = true;
    }

    function deposit() external payable onlyWhitelisted {
        require(address(this).balance <= maxBalance, "Max balance reached");
        balances[msg.sender] += msg.value;
    }

    function execute(address to, uint256 value, bytes calldata data) external payable onlyWhitelisted {
        require(balances[msg.sender] >= value, "Insufficient balance");
        balances[msg.sender] -= value;
        (bool success,) = to.call{value: value}(data);
        require(success, "Execution failed");
    }

    /**
     * Enables batching of multiple function calls into a single transaction using delegatecall.
     *
     * Delegatecall preserves msg.sender and msg.value across all calls,
     * so a single ETH transfer to `multicall()` can appear multiple times
     * inside internal deposit() calls, tricking the `balances` mapping.
     *
     * However, the `depositCalled` guard prevents calling `deposit()` more than once directly.
     * This restriction can be bypassed by nesting multicall calls:
     * - multicall -> multicall -> deposit
     * - This way, `deposit()` can be called multiple times in a single transaction.
     * - Each nested call still sees the full msg.value, leading to incorrect balances mapping crediting.
     */
    function multicall(bytes[] calldata data) external payable onlyWhitelisted {
        bool depositCalled = false;
        for (uint256 i = 0; i < data.length; i++) {
            bytes memory _data = data[i];
            bytes4 selector;
            assembly {
                selector := mload(add(_data, 32))
            }
            if (selector == this.deposit.selector) {
                require(!depositCalled, "Deposit can only be called once");
                // Protect against reusing msg.value
                depositCalled = true;
            }
            (bool success,) = address(this).delegatecall(data[i]);
            require(success, "Error while delegating call");
        }
    }
}
