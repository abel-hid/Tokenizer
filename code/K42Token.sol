// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// -----------------------------------------------------------------------
// K42 Token — an ERC-20 token built for the 42 "Tokenizer" project,
// targeting the Ethereum Sepolia testnet.
//
// This contract is meant to be opened and compiled directly in Remix
// (https://remix.ethereum.org). Remix automatically resolves the
// "@openzeppelin/contracts/..." import paths below via its built-in
// npm package resolver, so no local install step is required.
//
// ERC-20 is Ethereum's token standard. Building on top of OpenZeppelin's
// audited ERC20 implementation avoids re-implementing balance/allowance
// bookkeeping by hand.
// -----------------------------------------------------------------------

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
// Each import above pulls in one OpenZeppelin building block:
// - ERC20:          the core standard (balances, transfer, approve...)
// - ERC20Burnable:  adds burn() / burnFrom()
// - ERC20Pausable:  adds pause() / unpause() logic
// - Ownable:        adds the "single admin address" pattern (onlyOwner)
// None of this logic is written by hand here — it's reused from an
// audited library on purpose (see README.md for the reasoning).

/// @title K42Token
/// @notice An ERC-20 token named "K42 Token" (ticker: K42).
/// @dev Extends OpenZeppelin's ERC20 with:
///      - Burnable: any holder can destroy their own tokens.
///      - Pausable: the owner can freeze all transfers in an emergency
///        (e.g. a discovered bug or a compromised key), which is the
///        minimal "security / privilege" control asked for in the
///        subject.
///      - Ownable: a single admin address controls minting and pausing.
///        Ownership itself can be transferred or renounced, which is
///        documented explicitly in documentation/DOCUMENTATION.md.
contract K42Token is ERC20, ERC20Burnable, ERC20Pausable, Ownable {
    /// @notice Hard cap on total supply. Minting can never push
    ///         totalSupply() above this value, regardless of who
    ///         calls mint(). This protects holders from unlimited,
    ///         silent dilution by the owner.
    uint256 public immutable maxSupply;
    // "immutable" = this value is set exactly once, in the constructor
    // below, and is then baked permanently into the contract's bytecode.
    // Nobody — not the owner, not even a future contract upgrade (this
    // contract has no upgrade mechanism) — can ever change it again.
    // This is what makes the mint cap a real, trustworthy promise to
    // token holders rather than just a suggestion the owner could later
    // sidestep.

    /// @param initialSupply   Tokens (in whole units, no decimals) minted
    ///                        to the deployer at creation time.
    /// @param cap             Hard cap (in whole units) on total supply.
    constructor(uint256 initialSupply, uint256 cap)
        ERC20("K42 Token", "K42")   // sets the token's name + ticker
        Ownable(msg.sender)         // makes the deployer the initial owner
    {
        // Sanity checks run once, at deployment. If either fails, the
        // whole deployment transaction reverts and no contract is
        // created — better to fail loudly here than deploy a broken
        // token.
        require(cap > 0, "K42: cap must be > 0");
        require(initialSupply <= cap, "K42: initial supply exceeds cap");

        // decimals() returns 18 by default (inherited from ERC20). Token
        // amounts are always stored as whole numbers internally, so
        // "1 token" is actually stored as 1 * 10^18. We multiply the
        // human-friendly constructor inputs (e.g. 1000000) by that same
        // factor here so the rest of the contract's math stays
        // consistent with every other ERC-20 token.
        maxSupply = cap * (10 ** decimals());

        // Mint the starting supply directly to whoever deploys the
        // contract (msg.sender). This is the only place tokens are
        // created without going through the mint() function below.
        _mint(msg.sender, initialSupply * (10 ** decimals()));
    }

    /// @notice Mint new tokens. Restricted to the owner so that supply
    ///         growth is a deliberate, auditable admin action rather
    ///         than something any address can trigger.
    /// @param to     Recipient of the newly minted tokens.
    /// @param amount Amount to mint, expressed in the smallest unit
    ///               (i.e. already multiplied by 10 ** decimals()).
    function mint(address to, uint256 amount) external onlyOwner {
        // onlyOwner (from Ownable) makes this function revert
        // automatically if anyone other than the current owner calls
        // it — this is the access-control test: try calling mint()
        // from a non-owner account and it should fail.
        require(totalSupply() + amount <= maxSupply, "K42: cap exceeded");
        // This check is what actually enforces the cap. Without it,
        // the owner could mint an unlimited amount despite maxSupply
        // existing — the variable alone does nothing on its own, it
        // only matters because this line checks against it every time.
        _mint(to, amount);
    }

    /// @notice Pause all token transfers. Restricted to the owner.
    ///         Used as an emergency brake only (e.g. compromised owner
    ///         key rotation in progress, or a critical bug discovered
    ///         downstream). Minting and burning are also paused while
    ///         paused, since both call the same internal transfer hook.
    function pause() external onlyOwner {
        _pause();
        // _pause() is inherited from ERC20Pausable — it flips an
        // internal boolean that every transfer/mint/burn checks via
        // the _update() override below.
    }

    /// @notice Resume normal token transfers. Restricted to the owner.
    function unpause() external onlyOwner {
        _unpause();
    }

    // ------------------------------------------------------------------
    // The following override is required by Solidity whenever a
    // contract inherits from more than one base that defines
    // _update (ERC20 and ERC20Pausable both do). It simply chains the
    // call to both parents so pausing logic and normal transfer
    // accounting both run correctly.
    //
    // In plain terms: every transfer, mint, and burn in this contract
    // ultimately funnels through this one internal function. Solidity
    // forces us to explicitly say "run both parents' versions" because
    // two different imported contracts (ERC20 and ERC20Pausable) both
    // try to define this same function — without this override, the
    // compiler wouldn't know which one to use, or whether to use both.
    // super._update(...) below runs ERC20Pausable's version first
    // (which checks whenNotPaused and reverts if paused), then falls
    // through to ERC20's version (which actually updates balances).
    // ------------------------------------------------------------------
    function _update(address from, address to, uint256 value)
        internal
        override(ERC20, ERC20Pausable)
    {
        super._update(from, to, value);
    }
}
