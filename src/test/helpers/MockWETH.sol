// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.15;

// NOTE: node_modules style import replaced with forge import
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/// @title Interface for MockWETH
interface MockWETH is IERC20 {
    /// @notice Deposit ether to get wrapped ether
    function deposit() external payable;

    /// @notice Withdraw wrapped ether to get ether
    function withdraw(uint256) external;
}
