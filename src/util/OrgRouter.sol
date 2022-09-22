// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;
pragma abicoder v2;

import '@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol';
import '@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol';
import '@openzeppelin/contracts/token/ERC20/ERC20.sol';

import "forge-std/console.sol";

import {
    USDC,
    UNI_POOL
} from "../Constants.sol";

contract OrgRouter {

    ISwapRouter public immutable swapRouter;

    address public inputToken;
    ERC20 public inputERC20;

    uint24 public constant poolFee = 3000;

    event SwappedAndTransferred(
        address indexed donor,
        string inputTokenSymbol,
        uint256 amountIn,
        uint256 amountOut
    );

    /**
     * @dev Constructor
     * @param _swapRouter The Uniswap V3 Swap Router address
     * @param _usdcToken The address of the USDC token
     */
    constructor(address _swapRouter, address _usdcToken) {
        swapRouter = ISwapRouter(_swapRouter);
    }

    /**
     * @notice Sets the input token address and ERC20 token
     */
    function setinputToken(address _inputToken) external {
        inputToken = _inputToken;
        inputERC20 = ERC20(_inputToken);
    }


    /// @notice swapExactInputSingle swaps a fixed amount of input token for a maximum possible amount of USDC
    /// using the inputToken/USDC 0.3% pool by calling `exactInputSingle` in the swap router.
    /// @dev The calling address must approve this contract to spend at least `amountIn` worth of its input token for this function to succeed.
    /// @param amountIn The exact amount of the input token that will be swapped for USDC.
    /// @return amountOut The amount of USDC received.
    function swapExactInputSingle(uint256 amountIn, address donor) external returns (uint256 amountOut) {
        // msg.sender must approve this contract

        // Transfer straight to org if input token is USDC
        if (inputToken == USDC) {
            TransferHelper.safeTransferFrom(USDC, donor, msg.sender, amountIn);
            return amountIn;
        }

        // Else transfer the specified amount of input token to this contract.
        TransferHelper.safeTransferFrom(inputToken, donor, address(this), amountIn);

        // Approve the router to spend input token.
        TransferHelper.safeApprove(inputToken, address(swapRouter), amountIn);

        // amountOutMinimum is 0 becuase of simplicity anbd should be checked against oracle price for excessive price-impact.
        ISwapRouter.ExactInputSingleParams memory params =
            ISwapRouter.ExactInputSingleParams({
                tokenIn: inputToken,
                tokenOut: USDC,
                fee: poolFee,
                recipient: msg.sender,
                deadline: block.timestamp,
                amountIn: amountIn,
                amountOutMinimum: 0,
                sqrtPriceLimitX96: 0
            });

        // Call the swap router to swap input token for USDC.
        // **Actually execution**
        amountOut = swapRouter.exactInputSingle(params);

        emit SwappedAndTransferred(msg.sender, inputERC20.symbol(), amountIn, amountOut);

    }

    /// @notice swapExactOutputSingle swaps a minimum possible amount of input token for a fixed amount of USDC.
    /// @dev The calling address must approve this contract to spend its input token for this function to succeed. As the amount of input DAI is variable,
    /// the calling address will need to approve for a slightly higher amount, anticipating some variance.
    /// @param amountOut The exact amount of USDC to receive from the swap.
    /// @param amountInMaximum The amount of input token we are willing to spend to receive the specified amount of USDC.
    /// @return amountIn The amount of  USDC actually spent in the swap.
    function swapExactOutputSingle(uint256 amountOut, uint256 amountInMaximum, address applicant) external returns (uint256 amountIn) {

        // Transfer straight to org if input token is USDC
        if (inputToken == USDC) {
            TransferHelper.safeTransferFrom(USDC, applicant, msg.sender, amountOut);
            return amountOut;
        }

        // Transfer the specified amount of input token to this contract.
        TransferHelper.safeTransferFrom(inputToken, applicant, address(this), amountInMaximum);

        console.log("amount with org Router: ", ERC20(inputToken).balanceOf(address(this)));


        // Approve the router to spend the specifed `amountInMaximum` of input token.
        // In production, you should choose the maximum amount to spend based on oracles or other data sources to acheive a better swap.
        TransferHelper.safeApprove(inputToken, address(swapRouter), amountInMaximum);

        console.log("Allowance for uni router: ", inputERC20.allowance(address(this), address(swapRouter)));
        console.log("from org router: ", address(this), " to ", address(swapRouter));

        ISwapRouter.ExactOutputSingleParams memory params =
            ISwapRouter.ExactOutputSingleParams({
                tokenIn: inputToken,
                tokenOut: USDC,
                fee: poolFee,
                recipient: msg.sender,
                deadline: block.timestamp,
                amountOut: amountOut,
                amountInMaximum: amountInMaximum,
                sqrtPriceLimitX96: 0
            });

        console.log("DIS WOKRING", amountIn);


        // Executes the swap returning the amountIn needed to spend to receive the desired amountOut.
        amountIn = swapRouter.exactOutputSingle(params);

        console.log("DIS also  WORKING");

        // For exact output swaps, the amountInMaximum may not have all been spent.
        // If the actual amount spent (amountIn) is less than the specified maximum amount, we must refund the applicant and approve the swapRouter to spend 0.

        if (amountIn < amountInMaximum) {
            TransferHelper.safeApprove(inputToken, address(swapRouter), 0);
            TransferHelper.safeTransfer(inputToken, applicant, amountInMaximum - amountIn);
        }
    }
}
