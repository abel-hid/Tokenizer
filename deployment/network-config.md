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

- https://rpc.sepolia.org
- https://sepolia.drpc.org
- https://ethereum-sepolia-rpc.publicnode.com
- Your own Alchemy or Infura Sepolia endpoint, if you have an account
  with either (free tier is enough) — these tend to be the most stable.

## Note on Sepolia's lifecycle

Sepolia is Ethereum's primary public testnet, but it has an announced
end-of-life planned (currently expected around September 2026), with a
successor testnet arriving alongside it during a transition period. For
a project completed in the near term this doesn't matter, but if you
come back to this repo much later and the network seems dead, that's
likely why — check https://ethereum.org for the current recommended
testnet.
