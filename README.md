# Tokenizer — K42 Token

> A minimal, secure **ERC-20 token** built for the 42 *Tokenizer* project
> and deployed live on the **Ethereum Sepolia testnet**.

| | |
|---|---|
| **Token name** | K42 Token |
| **Ticker** | K42 |
| **Standard** | ERC-20 (OpenZeppelin v5) |
| **Decimals** | 18 |
| **Network** | Ethereum Sepolia Testnet (chain ID `11155111`) |
| **Contract address** | [`0xdFA7e43Cc47685cb4d668de5DE7ab07D044eEb22`](https://sepolia.etherscan.io/address/0xdFA7e43Cc47685cb4d668de5DE7ab07D044eEb22) |
| **Initial supply** | 1,000,005 K42 |
| **Max supply (hard cap)** | 10,000,000 K42 |

---

## Table of contents

1. [What this project is](#1-what-this-project-is)
2. [Repository structure](#2-repository-structure)
3. [How the token works](#3-how-the-token-works)
4. [Design choices and rationale](#4-design-choices-and-rationale)
5. [Security model](#5-security-model)
6. [Deploying it yourself](#6-deploying-it-yourself)
7. [Trying it out](#7-trying-it-out)
8. [Deployed contract](#8-deployed-contract)

---

## 1. What this project is

The goal of *Tokenizer* is to create, deploy, and document a digital
asset on a public blockchain, end to end:

- **Contract**: a token that follows an established standard.
- **Deployment**: the token lives on a public network where anyone can
  inspect it.
- **Documentation**: a clear explanation of how it works, who controls
  what, and how to use it.

K42 Token is a **demonstration token**. It doesn't represent any
real-world asset, and it only exists on a test network. No real money is
involved at any stage: gas is paid with free Sepolia ETH from public
faucets.

## 2. Repository structure

```
.
├── README.md                  # Project overview, choices and rationale (this file)
├── code/
│   └── K42Token.sol           # The token's Solidity source code
├── deployment/
│   ├── HOW_TO_DEPLOY.md       # Step-by-step Remix + MetaMask deployment guide
│   ├── network-config.md      # Sepolia RPC, chain ID, explorer and faucets
│   └── DEPLOYMENT_INFO.md     # Record of the live deployment (address, owner, tx)
└── documentation/
    └── DOCUMENTATION.md       # Full token documentation: functions, usage, security
```

## 3. How the token works

`K42Token` combines four audited OpenZeppelin building blocks and adds a
small amount of custom logic on top:

```
                 ┌──────────────────────────────┐
                 │           K42Token           │
                 │  + maxSupply (immutable cap) │
                 │  + mint()      [owner only]  │
                 │  + pause()     [owner only]  │
                 │  + unpause()   [owner only]  │
                 └──────────────┬───────────────┘
        ┌─────────────┬─────────┴────┬──────────────┐
     ERC20      ERC20Burnable   ERC20Pausable     Ownable
  (balances,    (burn,          (freeze all      (single admin,
   transfers,    burnFrom)       token moves)     transfer/renounce)
   allowances)
```

### Functions available to everyone

| Function | What it does |
|---|---|
| `transfer(to, amount)` | Send tokens to another address |
| `approve(spender, amount)` | Allow another address to spend your tokens, up to `amount` |
| `transferFrom(from, to, amount)` | Move tokens on someone's behalf, using an approved allowance |
| `balanceOf(account)` | Read an address's balance |
| `totalSupply()` | Read the number of tokens currently in existence |
| `maxSupply()` | Read the hard cap on total supply |
| `burn(amount)` / `burnFrom(account, amount)` | Permanently destroy tokens, reducing total supply |

### Owner-only functions

| Function | What it does |
|---|---|
| `mint(to, amount)` | Create new tokens. Reverts if it would push `totalSupply()` above `maxSupply` |
| `pause()` / `unpause()` | Freeze or resume **every** transfer, mint and burn |
| `transferOwnership(newOwner)` | Hand admin rights to another address (for example a multisig) |
| `renounceOwnership()` | Give up admin rights permanently. Minting and pausing then become impossible |

> **Units:** the constructor takes **whole tokens** (for example
> `1000000`). `mint()` takes the **smallest unit**, so to mint 1 K42 you
> pass `1000000000000000000` (1 × 10¹⁸).

## 4. Design choices and rationale

**Chain: Ethereum (Sepolia testnet).**
The subject allows any blockchain as long as its token standard is
respected; BNB Chain is only given as an example. Ethereum was chosen
because ERC-20 is its native standard and the best-supported tooling
(OpenZeppelin, Remix, Etherscan, MetaMask) is built around it. Sepolia
is Ethereum's recommended public testnet, so the token behaves exactly
as it would on mainnet without risking real funds.

**Standard: ERC-20.**
ERC-20 defines a common interface (`transfer`, `approve`,
`transferFrom`, `balanceOf`, `totalSupply`, plus the `Transfer` and
`Approval` events). Following it makes K42 automatically compatible with
wallets, block explorers and decentralized exchanges across the Ethereum
ecosystem.

**Base implementation: OpenZeppelin, not hand-written.**
Balance and allowance bookkeeping is the easiest place to introduce
subtle, costly bugs. OpenZeppelin's contracts are the industry reference
implementation and have been widely audited, so rewriting that logic by
hand would add risk without adding value. The original work in this
project is what sits on top: the immutable supply cap, the owner-only
mint and pause controls, and how they're wired together through the
`_update` override.

**Tooling: Remix + MetaMask only.**
There's no Hardhat, Truffle or local Node project. The contract is
written, compiled and deployed entirely in the browser with Remix, which
resolves the OpenZeppelin imports automatically. MetaMask signs the
deployment transaction. That keeps the setup reproducible on any machine,
with nothing to install.

**Name: "K42 Token", ticker "K42".**
This meets the subject's requirement that the name contain "42", and it
stays short and readable as a ticker.

**Supply set at deploy time.**
The initial supply and the cap are constructor arguments rather than
hardcoded constants, so the same source can be redeployed with different
parameters without editing code. The constructor rejects invalid inputs
(a zero cap, or an initial supply above the cap), so a misconfigured
token can never be deployed.

## 5. Security model

The full threat model is in
[documentation/DOCUMENTATION.md §5](documentation/DOCUMENTATION.md). In
short:

- **One privileged role.** The deployer becomes the owner (via
  `Ownable`) and is the only address that can `mint` or
  `pause`/`unpause`. Every other function is permissionless.
- **Hard-capped minting.** `maxSupply` is `immutable`: it's written once
  in the constructor and stored in the contract's bytecode, so nobody can
  raise it later, the owner included. Even if the owner key were
  compromised, dilution could never go beyond the cap.
- **A blunt emergency brake rather than a censorship tool.** `pause()`
  freezes token movements for *everyone*, the owner included. There is
  deliberately **no** blacklist, per-address freezing or forced-transfer
  function, which keeps the privileged attack surface small and easy to
  audit.
- **No upgrade mechanism.** The deployed code is final. What you read in
  `code/K42Token.sol` is exactly what runs on-chain.
- **Clear path to decentralization.** Ownership can be moved to a
  multisig with `transferOwnership`, which is the natural route to the
  bonus multisig requirement. It can also be renounced entirely, which
  makes the supply permanently fixed.

## 6. Deploying it yourself

The short version (full walkthrough in
[deployment/HOW_TO_DEPLOY.md](deployment/HOW_TO_DEPLOY.md)):

1. Install **MetaMask** and switch to the **Sepolia** network (see
   [deployment/network-config.md](deployment/network-config.md)).
2. Get free Sepolia ETH from a faucet.
3. Open [Remix](https://remix.ethereum.org) and paste in
   `code/K42Token.sol`.
4. Compile with Solidity **0.8.20 or later**.
5. In *Deploy & Run Transactions*, select **Injected Provider -
   MetaMask**, enter `initialSupply` and `cap` in whole tokens, then
   click **Deploy**.

## 7. Trying it out

From Remix (*At Address* → paste the contract address), or from the
**Read/Write Contract** tabs on Etherscan once the contract is verified,
you can demonstrate every feature:

1. `balanceOf(owner)` shows the initial supply.
2. `transfer` some tokens to a second account; both balances update.
3. `approve` a third account, then call `transferFrom` from it; the
   allowance decreases and the tokens move.
4. `mint` as the owner; `totalSupply()` increases and stays at or below
   `maxSupply`.
5. `mint` from a **non-owner** account. This reverts, which proves the
   access control works.
6. `burn` some tokens; `totalSupply()` decreases.
7. `pause`, then try a `transfer`. It reverts. `unpause`, and transfers
   work again.

## 8. Deployed contract

| | |
|---|---|
| **Network** | Ethereum Sepolia Testnet (chain ID `11155111`) |
| **Contract address** | `0xdFA7e43Cc47685cb4d668de5DE7ab07D044eEb22` |
| **Ticker** | K42 |
| **Owner / deployer** | `0xb02452b0824a19E74A144fE0Fe2D1ccC2ed9d669` |
| **Etherscan** | https://sepolia.etherscan.io/address/0xdFA7e43Cc47685cb4d668de5DE7ab07D044eEb22 |
| **Creation transaction** | https://sepolia.etherscan.io/tx/0x1357bae20973e68400084feb1f98fbf102068353ab7e9a3bfff0b2aa1c1d0a03 |

The full deployment record, including verification status, is in
[deployment/DEPLOYMENT_INFO.md](deployment/DEPLOYMENT_INFO.md).
