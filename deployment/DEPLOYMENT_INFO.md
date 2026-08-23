# Deployment record

Fill this in immediately after deploying via `HOW_TO_DEPLOY.md`, and
mirror the key details into the root `README.md` as required by the
project subject.

- **Token name:** K42 Token
- **Ticker / symbol:** K42
- **Network:** Ethereum Sepolia Testnet (chain ID 11155111)
- **Contract address:** `0xdFA7e43Cc47685cb4d668de5DE7ab07D044eEb22`
- **Etherscan link:** https://sepolia.etherscan.io/address/0xdFA7e43Cc47685cb4d668de5DE7ab07D044eEb22
- **Verified on Etherscan:** pending confirmation see note below
- **Initial supply:** 1,000,005 K42
- **Max supply (cap):** 10,000,000 K42
- **Deployer / owner address:** `0xb02452b0824a19E74A144fE0Fe2D1ccC2ed9d669`
- **Contract creation transaction:** https://sepolia.etherscan.io/tx/0x1357bae20973e68400084feb1f98fbf102068353ab7e9a3bfff0b2aa1c1d0a03

**Note on verification:** Etherscan's TokenTracker already displays this
contract as "K42 Token (K42)", which it can infer directly from the
contract's public `name()`/`symbol()` functions without full source
verification. However, submitting through "Verify and Publish" (see
`deployment/HOW_TO_DEPLOY.md` section 5) is a separate, stronger step —
it publishes the actual Solidity source so anyone (including an
evaluator) can read the full commented code directly on Etherscan's
"Contract" tab. This should still be completed before final submission.
