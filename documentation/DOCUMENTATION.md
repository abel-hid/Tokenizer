# K42 Token — Documentation

## 1. What is K42 Token?

K42 Token (ticker: **K42**) is an ERC-20 fungible token deployed on the
Ethereum **Sepolia testnet**. It was built for the "Tokenizer"
project, whose goal is to demonstrate a working, minimal, secure token
end-to-end: contract, deployment, and public verification.

It does not represent any real-world asset or currency — it is a
demonstration token used purely for learning and evaluation purposes on a
test network. No real funds are ever involved.

## 2. Standard used

K42 Token implements the **ERC-20** standard, Ethereum's native token
standard. It is built on top of OpenZeppelin's audited `ERC20`
implementation rather than a hand-rolled one, for the reasons explained
in the root `README.md`.

## 3. Token parameters

| Parameter      | Value                                  |
|-----------------|-----------------------------------------|
| Name            | K42 Token                              |
| Symbol          | K42                                     |
| Decimals        | 18 (standard ERC-20 default)            |
| Initial supply  | set at deploy time (constructor arg)    |
| Max supply      | hard cap, set at deploy time and immutable afterwards |
| Network         | Ethereum Sepolia Testnet (chain ID 11155111) |

The exact initial supply, cap, contract address, and deployment
transaction are recorded in `deployment/DEPLOYMENT_INFO.md` once the
contract has actually been deployed.

## 4. Functionality

Standard ERC-20 functions available to any holder:

- `transfer(to, amount)` — send tokens to another address.
- `approve(spender, amount)` / `transferFrom(from, to, amount)` — allow a
  third party (e.g. a contract) to move tokens on your behalf, up to an
  approved allowance.
- `balanceOf(address)` — check any address's balance.
- `totalSupply()` — check current circulating supply.
- `burn(amount)` / `burnFrom(account, amount)` (from `ERC20Burnable`) —
  permanently destroy tokens, reducing total supply.

Owner-only (privileged) functions:

- `mint(to, amount)` — create new tokens, capped by `maxSupply`. Restricted
  to the contract owner so supply growth is a deliberate, auditable
  action, not something any address can trigger.
- `pause()` / `unpause()` — freeze or resume **all** transfers, mints, and
  burns network-wide. Intended purely as an emergency brake (e.g. a
  critical bug is found, or the owner key needs rotating) — not for
  routine use.
- Standard `Ownable` functions: `transferOwnership(newOwner)` and
  `renounceOwnership()`.

## 5. Security model / privileges

- A **single owner address** (the deployer, by default) holds all
  privileged rights: minting and pausing.
- Minting is **capped**: `maxSupply` is set once at deployment and is
  `immutable` — it cannot be changed afterwards by anyone, including the
  owner. This bounds the maximum possible dilution regardless of who
  controls the owner key in the future.
- Pausing affects everyone equally, including the owner — it is a
  circuit breaker, not a way to selectively block specific users.
- There is no hidden backdoor: blacklisting, forced transfers, or
  address-specific freezing are intentionally **not** implemented, to
  keep the privileged surface area small and easy to audit.
- Ownership can be transferred (e.g. to a multisig wallet or DAO) or
  permanently renounced via the inherited `Ownable` functions, which
  would remove all privileged control from any single key.

## 6. How to use it
These are the minimal actions used to demonstrate the token is working,
performed from Remix's "Deploy & Run Transactions" tab against the
deployed testnet contract (see `deployment/HOW_TO_DEPLOY.md`):

1. **Deploy** the contract with an initial supply and a cap — the
   deployer's balance should equal the initial supply.
2. **Transfer** some tokens from the deployer to a second test account —
   confirm both balances update correctly via `balanceOf`.
3. **Approve + transferFrom** — approve a third account to spend a small
   allowance, then have that account call `transferFrom` — confirm the
   allowance decreases and tokens move.
4. **Mint** (as owner) — mint additional tokens to a test account, confirm
   `totalSupply()` increases and stays within `maxSupply`.
5. **Mint as a non-owner** — attempting this from a different account must
   revert, demonstrating the access control actually works.
6. **Burn** — burn a small amount from a holder, confirm `totalSupply()`
   decreases.
7. **Pause / unpause** (as owner) — pause the contract, confirm a
   `transfer` call reverts while paused, then unpause and confirm
   transfers work again.

## 7. Where to find the deployed contract

Once deployed, the contract address, network, and a link to it on the
Sepolia block explorer (sepolia.etherscan.io) are recorded in
`deployment/DEPLOYMENT_INFO.md`.
