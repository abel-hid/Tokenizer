# Ethereum Sepolia Testnet — network configuration

| Field           | Value                                                    |
|-----------------|-----------------------------------------------------------|
| Network name    | Sepolia                                                    |
| Chain ID        | 11155111                                                    |
| Currency symbol | ETH (SepoliaETH — no real value)                            |
| Block explorer  | https://sepolia.etherscan.io                                |
| Faucets         | https://faucets.chain.link/sepolia                          |
|                 | https://cloud.google.com/application/web3/faucet/ethereum/sepolia |

## Getting a working RPC URL

The most reliable way to add Sepolia to MetaMask is via **Chainlist**
(https://chainlist.org/chain/11155111) — connect your wallet and click
"Add to MetaMask". It tests endpoints live and only offers ones that are
currently responding, which avoids the "Could not fetch chain ID" error
that manually-typed public RPCs sometimes trigger when they're
rate-limited or temporarily down.

If you'd rather enter one manually, try (in order, in case one is down):

- https://sepolia.drpc.org
- https://ethereum-sepolia-rpc.publicnode.com

