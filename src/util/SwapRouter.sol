// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;
pragma abicoder v2;

import '@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol';
import '@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol';
import '@openzeppelin/contracts/token/ERC20/ERC20.sol';

contract SwapRouter {

    ISwapRouter public immutable swapRouter;

    address public inputToken;
    ERC20 public inputERC20;
    address public immutable USDC;
    address public orgContract;

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
        USDC = _usdcToken;
    }

    /**
     * @notice Sets the input token address and ERC20 token
     */
    function setinputToken(address _inputToken) external {
        inputToken = _inputToken;
        inputERC20 = ERC20(_inputToken);
    }


    /**
     * @notice Sets the org contract address
     */
    function setOrgContract(address _orgContract) external {
        orgContract = _orgContract;
    }

    /// @notice swapExactInputSingle swaps a fixed amount of input token for a maximum possible amount of USDC
    /// using the inputToken/USDC 0.3% pool by calling `exactInputSingle` in the swap router.
    /// @dev The calling address must approve this contract to spend at least `amountIn` worth of its input token for this function to succeed.
    /// @param amountIn The exact amount of the input token that will be swapped for USDC.
    /// @return amountOut The amount of USDC received.
    function swapExactInputSingle(uint256 amountIn) external returns (uint256 amountOut) {
        // msg.sender must approve the org contract

        // Transfer the specified amount of input token to this contract.
        TransferHelper.safeTransferFrom(inputToken, msg.sender, address(this), amountIn);

        // Approve the router to spend input token.
        TransferHelper.safeApprove(inputToken, address(swapRouter), amountIn);

        // amountOutMinimum is 0 becuase of simplicity anbd should be checked against oracle price for excessive price-impact.
        ISwapRouter.ExactInputSingleParams memory params =
            ISwapRouter.ExactInputSingleParams({
                tokenIn: inputToken,
                tokenOut: USDC,
                fee: poolFee,
                recipient: orgContract,
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

}
