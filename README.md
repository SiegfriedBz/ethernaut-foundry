# 🧠 Ethernaut Challenge Solutions (Foundry)

This repository contains my personal solutions to the [Ethernaut](https://ethernaut.openzeppelin.com/) smart contract security challenges, implemented using [Foundry](https://book.getfoundry.sh/).

Each branch contains a specific Ethernaut contract along with its associated solution script in the script/ directory, where I write and execute the exploit against a deployed Ethernaut challenge instance.

---

## ⚙️ Setup

### 1. 📄 Configure Environment Variables

Start by copying the example .env file:

```bash
cp .env.example .env
```

Then fill in your own values in .env:

```bash
ALCHEMY_SEPOLIA_RPC_URL=https://eth-sepolia.g.alchemy.com/v2/your_key_here
ETHERSCAN_KEY=your_etherscan_api_key_here
PRIVATE_KEY=0x...your_private_key_here
```

🔐 Do not commit .env — it contains sensitive keys!

## 🚀 Running Challenge Scripts

### 2. ✅ Simulate an Exploit (Dry Run)

Run the script locally to test without sending transactions:

```bash
source .env
forge script script/<YourScriptFile>.s.sol \
 --tc <TargetContractName> \
 --rpc-url $ALCHEMY_SEPOLIA_RPC_URL
```

<YourScriptFile>: name of the script file (e.g. FallbackScript)
<TargetContractName>: the contract in that script file containing the logic

ℹ️ Use the --tc (--target-contract) flag when the script file contains multiple contracts.

### 3. 📡 Broadcast the Exploit (Send to Sepolia)

Send the transaction to the Sepolia testnet:

```bash
source .env
forge script script/<YourScriptFile>.s.sol \
 --tc <TargetContractName> \
 --rpc-url $ALCHEMY_SEPOLIA_RPC_URL \
 --broadcast
```

Make sure your Sepolia wallet has test ETH.

🧪 Example

```bash
source .env
forge script script/FallbackScript.s.sol \
 --tc FallbackScript \
 --rpc-url $ALCHEMY_SEPOLIA_RPC_URL \
 --broadcast
```

🌱 Branch Structure
Each branch in this repository corresponds to a specific Ethernaut challenge. Every branch contains:

The Ethernaut contract for the challenge

The script inside the script/ folder with the solution/exploit
