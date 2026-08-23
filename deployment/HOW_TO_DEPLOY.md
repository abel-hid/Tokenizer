# Deploying K42 Token via Remix (no local tooling required)

This project intentionally uses only **Remix IDE** + **MetaMask**, no
Hardhat/Truffle/local Node setup. Everything below happens in the browser.

## 0. Prerequisites

- [MetaMask](https://metamask.io/) browser extension installed.
- A little patience — testnet faucets are sometimes slow/rate-limited.

## 1. Add Ethereum Sepolia to MetaMask

Sepolia is usually already built into MetaMask's default network list
(toggle "Show test networks" in Settings → General if you don't see it).
If it's not there, the easiest way to add it correctly is via
**Chainlist**: go to https://chainlist.org/chain/11155111, connect
MetaMask, click "Add to MetaMask" — it auto-picks a live RPC endpoint.

To add manually instead:

| Field             | Value                                 |
|-------------------|-----------------------------------------|
| Network name      | Sepolia                                |
| New RPC URL       | see `deployment/network-config.md` for current working endpoints |
| Chain ID          | `11155111`                              |
| Currency symbol   | `ETH` (technically SepoliaETH)          |
| Block explorer    | `https://sepolia.etherscan.io`          |

## 2. Get free Sepolia ETH

Use any of these (having more than one option matters — faucets rate-limit
per address/day):

- https://faucets.chain.link/sepolia (Chainlink faucet, needs a small
  amount of mainnet activity on your address in some versions)
- https://cloud.google.com/application/web3/faucet/ethereum/sepolia
  (Google Cloud faucet)
- Your RPC provider's faucet if you signed up with Alchemy/Infura — they
  often include a Sepolia faucet in their dashboard.

Connect the MetaMask account you'll deploy from and request Sepolia ETH.
It has no real value — it's gas money only.

## 3. Open the contract in Remix

1. Go to https://remix.ethereum.org
2. Create a new file, e.g. `K42Token.sol`, and paste in the contents of
   `code/K42Token.sol` from this repository.
3. Go to the **Solidity Compiler** tab (left sidebar).
   - Set the compiler version to `0.8.20` or later (must satisfy
     `pragma solidity ^0.8.20;`).
   - Click **Compile K42Token.sol**.
   - Remix automatically fetches the `@openzeppelin/contracts/...`
     imports over the network the first time you compile — no manual
     `npm install` needed.

## 4. Deploy to Sepolia

1. Go to the **Deploy & Run Transactions** tab.
2. Under "Environment", choose **Injected Provider - MetaMask**.
   MetaMask will prompt you to connect — make sure it's connected to
   **Sepolia**, not Ethereum mainnet (double-check the network name
   shown in the Remix environment dropdown after connecting).
3. Under "Contract", select `K42Token`.
4. Fill in the constructor arguments:
   - `initialSupply`: e.g. `1000000` (1,000,000 whole tokens minted to
     you at deploy time)
   - `cap`: e.g. `10000000` (10,000,000 whole tokens, hard ceiling on
     future minting)
5. Click **Deploy**, confirm the transaction in MetaMask.
6. Once mined, copy the deployed contract address from the "Deployed
   Contracts" panel in Remix.

## 5. Verify on the block explorer

1. Go to https://sepolia.etherscan.io and search for your contract
   address.
2. Open the "Contract" tab → "Verify and Publish".
3. Choose "Solidity (Single file)" (or "Standard-JSON-Input" — in Remix,
   click the small "gear" icon next to the compile button →
   "Compilation Details" → copy the generated Standard JSON Input,
   which is the most reliable way to verify a contract that has
   imports).
4. Match the exact compiler version and optimization settings you used
   in Remix, then submit.
5. Once verified, the "Read Contract" / "Write Contract" tabs on
   Etherscan let you call `balanceOf`, `transfer`, `mint`, `pause`, etc.
   directly from the explorer UI — a convenient way to run the
   demonstration steps in `documentation/DOCUMENTATION.md` section 6.

## 6. Record the result

Fill in `deployment/DEPLOYMENT_INFO.md` with the final contract address,
network, ticker, and Etherscan link, and also add these to the root
`README.md` as required by the project subject.
