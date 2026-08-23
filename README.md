# Tokenizer — K42 Token

An ERC-20 token built for the 42 "Tokenizer" project, deployed on the
Ethereum Sepolia testnet.

## Repository structure

```
.
├── README.md                       # this file — choices & rationale
├── code/
│   └── K42Token.sol                # the token's Solidity source
├── deployment/
│   ├── HOW_TO_DEPLOY.md            # step-by-step Remix + MetaMask guide
│   ├── network-config.md           # Sepolia RPC / chain details
│   └── DEPLOYMENT_INFO.md          # contract address & network, filled
│                                    # in after deploying
└── documentation/
    └── DOCUMENTATION.md            # what the token is, how it works,
                                     # how to use it, security model
```

## Choices made, and why

**Chain: Ethereum (Sepolia testnet).**
The subject allows any chain as long as its token standard is respected,
and gives BNB Chain only as an example. This project targets Ethereum
Sepolia instead, since ERC-20 is the standard the underlying tooling
(OpenZeppelin, Remix, Etherscan) is built around most directly. No real
funds are used at any point — Sepolia ETH from public faucets only.

**Standard: ERC-20.**
ERC-20 is Ethereum's native token standard (`transfer`, `approve`,
`transferFrom`, `balanceOf`, `totalSupply`, `Transfer`, `Approval`).
Building to this standard means the token is automatically compatible
with wallets, explorers, and DEXs across the Ethereum ecosystem.

**Base implementation: OpenZeppelin, not hand-rolled.**
Rather than writing ERC20 bookkeeping (balances, allowances, overflow
handling) from scratch, the contract extends OpenZeppelin's `ERC20`
contracts. OpenZeppelin's implementations are widely audited and
battle-tested; re-implementing the same logic by hand would only add
risk without adding anything the project asks for. What *is* original
here is the extra logic layered on top: the mint cap, the pause switch,
and how they're wired together.

**Tooling: Remix only.**
No Hardhat/Truffle/local Node project — the contract is written and
compiled directly in Remix, and deployed via Remix's "Injected Provider"
using MetaMask. This keeps the whole pipeline in the browser and avoids
any local environment/dependency issues. See `deployment/HOW_TO_DEPLOY.md`
for the exact steps, and `deployment/network-config.md` for the Sepolia
RPC/chain parameters.

**Token name: "K42 Token", ticker "K42".**
Satisfies the "must contain 42" constraint from the subject while
staying short and readable as a ticker.

**Security / privilege design (see `documentation/DOCUMENTATION.md`
section 5 for full detail):**
- A single **owner** address (the deployer, via OpenZeppelin's
  `Ownable`) holds the only two privileged powers: `mint` and
  `pause`/`unpause`.
- Minting is **hard-capped** by an `immutable maxSupply` set once at
  deployment — nobody, including the owner, can raise it later. This
  bounds worst-case dilution regardless of who ends up controlling the
  owner key.
- `pause()` is a blunt, global emergency brake (freezes transfers,
  mints, and burns for everyone, including the owner) — not a
  selective blacklist. There is no per-address freezing or forced
  transfer capability, to keep the privileged attack surface small.
- Ownership can be transferred (e.g. to a multisig) or renounced via
  the inherited `Ownable` functions, which is the natural upgrade path
  if this were ever adapted for the bonus multisig requirement.

**Supply parameters (initial supply and cap) are chosen at deploy
time**, as constructor arguments, rather than hardcoded, so the same
contract source can be reused/redeployed with different parameters
without editing code.

## Deployed contract

- **Network:** Ethereum Sepolia Testnet (chain ID 11155111)
- **Contract address:** `0xdFA7e43Cc47685cb4d668de5DE7ab07D044eEb22`
- **Ticker:** K42
- **Etherscan:** https://sepolia.etherscan.io/address/0xdFA7e43Cc47685cb4d668de5DE7ab07D044eEb22

See `deployment/DEPLOYMENT_INFO.md` for full details (initial supply, cap,
owner address, verification status).
