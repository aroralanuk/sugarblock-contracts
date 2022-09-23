// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import "./helpers/BaseTest.sol";
import "forge-std/console2.sol";
import "forge-std/Vm.sol";
import "forge-std/console.sol";

import { IQuoter } from "@uniswap/v3-periphery/contracts/interfaces/IQuoter.sol";

import { Org } from "../Org.sol";
import { SBToken } from "../SBToken.sol";
import { SBFactory } from "../SBFactory.sol";

import { MockWETH } from "./helpers/MockWETH.sol";

import {
    WETH,
    USDC,
    DAI,
    UNI_ROUTER,
    UNI_QUOTER,
    SLIPPAGE_TOLERANCE
} from "../Constants.sol";

import '@openzeppelin/contracts/token/ERC20/ERC20.sol';


contract SBFactoryTest is BaseTest {
    // Vm private vm = Vm(HEVM_ADDRESS);
    uint256 mainnetFork;
    string MAINNET_RPC_URL = vm.envString("MAINNET_RPC_URL");

    address internal deployer = 0xb4c79daB8f259C7Aee6E5b2Aa729821864227e84;

    address internal orgRouterAddress;
    SBFactory internal factory;

    function setUp() public {
        factory = new SBFactory(UNI_ROUTER, USDC);
        orgRouterAddress = factory.getOrgRouter();

        factory.createOrg("RedCross");
        factory.createOrg("Gitcoin");
        factory.createOrg("WorldCoin");

        Org redCross = factory.orgs(0);
        redCross.createBounty(
            "COVID-19 drug discovery research",
            1000e6,
            block.timestamp + 7 days
        );
        redCross.createBounty(
            "Safe transport of vaccines in Libya",
            1e16,
            block.timestamp + 7 days
        );
        redCross.openBounty(1);
        redCross.openBounty(2);
    }

    function testCreatOrg() public {
        factory.createOrg("Celo");
        Org _celo = factory.orgs(3);

        assertEq(_celo.name(), "Celo");
        assertEq(_celo.admin(), deployer);
    }

    function testCreateBounty() public {

        Org redCross = factory.orgs(0);
        uint256 bountyDeadline = block.timestamp + 8 days;
        redCross.createBounty(
            "Funding alex P - Tornado Cash dev",
            15e15,
            block.timestamp + 8 days
        );

        (
            string memory title,
            uint256 stakeReqd,
            uint256 deadline,
            bool open
        ) = redCross.bounties(3);

        assertEq(title, "Funding alex P - Tornado Cash dev");
        assertEq(stakeReqd, 15e15);
        assertEq(deadline, bountyDeadline);
        assertEq(open, false);
    }

    function testCreateBountyFail_NotAdmin() public {
        Org redCross = factory.orgs(0);
        vm.prank(adele);
        vm.expectRevert("ERROR: caller is not the admin");
        redCross.createBounty("Help the poor", 1e16, block.timestamp + 7 days);
    }

    function testCreateBountyFail_DiffAdmin() public {
        Org redCross = factory.orgs(0);
        Org gitcoin = factory.orgs(1);
        gitcoin.transferAdmin(adele);

        vm.startPrank(adele);
        gitcoin.createBounty("Build a DAO dashboard", 1e16, block.timestamp + 7 days);

        vm.expectRevert("ERROR: caller is not the admin");
        redCross.createBounty("Help the poor", 1e16, block.timestamp + 7 days);
        vm.stopPrank();
    }

    function testOpenBounty() public {
        Org redCross = factory.orgs(0);
        redCross.openBounty(1);

        ( , , , bool open ) = redCross.bounties(1);
        assertEq(open, true);
    }

    function testDonate_USDC() public {
        Org redCross = factory.orgs(0);

        vm.startPrank(adele);

        (bool success, ) = USDC.call(
            abi.encodeWithSignature(
                "approve(address,uint256)",
                orgRouterAddress,
                1200e6
            )
        );
        assertTrue(success);

        redCross.donateToBounty(1, USDC, 1000e6);

        vm.stopPrank();

        ( uint256 amount ) = redCross.donations(1, adele);
        assertEq(amount, 1000e6);
        assertEq(ERC20(USDC).balanceOf(address(redCross)), 1000e6);
    }

    function testDonate_DAI() public {
        Org redCross = factory.orgs(0);

        vm.startPrank(adele);

        (bool success, ) = DAI.call(
            abi.encodeWithSignature(
                "approve(address,uint256)",
                orgRouterAddress,
                1200e6
            )
        );
        assertTrue(success);

        redCross.donateToBounty(1, DAI, 1000e6);

        vm.stopPrank();

        ( uint256 amount ) = redCross.donations(1, adele);

        uint256 quote = _quotePrice(DAI, USDC, 1200e6);
        assertApproxEqRel(
            amount,
            quote,
            SLIPPAGE_TOLERANCE
        );

        assertApproxEqRel(
            ERC20(USDC).balanceOf(address(redCross)),
            quote,
            SLIPPAGE_TOLERANCE
        );
    }

    function testDonate_WETH() public {
        Org redCross = factory.orgs(0);


        vm.startPrank(adele);

        (bool success, ) = WETH.call(
            abi.encodeWithSignature(
                "approve(address,uint256)",
                orgRouterAddress,
                1e18
            )
        );
        assertTrue(success);

        redCross.donateToBounty(1, WETH, 1e18);

        vm.stopPrank();

        ( uint256 amount ) = redCross.donations(1, adele);

        uint256 quote = _quotePrice(WETH, USDC, 1e18);
        assertApproxEqRel(
            amount,
            quote,
            SLIPPAGE_TOLERANCE
        );

        assertApproxEqRel(
            ERC20(USDC).balanceOf(address(redCross)),
            quote,
            SLIPPAGE_TOLERANCE
        );
    }

    function testApply_success() public {
        Org redCross = factory.orgs(0);

        vm.startPrank(bob);

        (bool success, ) = USDC.call(
            abi.encodeWithSignature(
                "approve(address,uint256)",
                orgRouterAddress,
                1200e6
            )
        );
        assertTrue(success);

        console.log("Allowance: ", ERC20(USDC).allowance(bob, orgRouterAddress));

        redCross.applyToBounty(1, USDC, 1200e6);

        vm.stopPrank();

        ( Org.AppStatus status ) = redCross.applicantStatus(1, bob);
        assertEq(uint256(status), 1);

        assertEq(ERC20(USDC).balanceOf(address(redCross)), 1000e6);
    }

    function testApply_successWETH() public {
        Org redCross = factory.orgs(0);

        vm.startPrank(bob);
        uint256 bal0 = ERC20(WETH).balanceOf(bob);
        (bool success, ) = WETH.call(
            abi.encodeWithSignature(
                "approve(address,uint256)",
                orgRouterAddress,
                1e18
            )
        );
        assertTrue(success);
        redCross.applyToBounty(1, WETH, 1e18);
        vm.stopPrank();

        uint256 bal1 = ERC20(WETH).balanceOf(bob);
        ( Org.AppStatus status ) = redCross.applicantStatus(1, bob);
        assertEq(uint256(status), 1);

        assertApproxEqRel(
            ERC20(USDC).balanceOf(address(redCross)),
            1000e6,
            SLIPPAGE_TOLERANCE
        );

        assertApproxEqRel(
            bal0 - bal1,
             _quotePrice(USDC, WETH, 1000e6),
            SLIPPAGE_TOLERANCE
        );
    }

    function testApply_AdminFail() external {
        Org redCross = factory.orgs(0);

        (bool success, ) = USDC.call(
            abi.encodeWithSignature(
                "approve(address,uint256)",
                orgRouterAddress,
                1200e6
            )
        );
        assertTrue(success);

        vm.expectRevert("ERROR: admin cannot apply to own bounty");
        redCross.applyToBounty(1, USDC, 1200e6);
    }

    function testSubmitBounty() external {
        Org redCross = factory.orgs(0);

        vm.startPrank(bob);

        (bool success, ) = WETH.call(
            abi.encodeWithSignature(
                "approve(address,uint256)",
                orgRouterAddress,
                2e18
            )
        );

        redCross.applyToBounty(1, WETH, 2e18);
        redCross.submitBounty(1, keccak256("test"));
        vm.stopPrank();

        ( Org.AppStatus status ) = redCross.applicantStatus(1, bob);
        assertEq(uint256(status), 1);

        ( bytes32 ipfsHash ) = redCross.submittedHashes(1, bob);
        assertEq(ipfsHash, keccak256("test"));

    }

    function testSubmitBounty_noApplyFail() external {
        Org redCross = factory.orgs(0);

        vm.startPrank(bob);

        (bool success, ) = WETH.call(
            abi.encodeWithSignature(
                "approve(address,uint256)",
                orgRouterAddress,
                1e18
            )
        );

        redCross.applyToBounty(1, WETH, 1e18);

        vm.expectRevert("ERROR: applicant must have applied");
        redCross.submitBounty(2, keccak256("test"));

        vm.stopPrank();
    }

    function testSubmitBounty_deadlinePassedFail() external {
        Org redCross = factory.orgs(0);

        vm.startPrank(bob);
        (bool success, ) = WETH.call(
            abi.encodeWithSignature(
                "approve(address,uint256)",
                orgRouterAddress,
                2e18
            )
        );
        redCross.applyToBounty(1, WETH, 2e18);
        skip(7 days);

        vm.expectRevert("ERROR: deadline passed");
        redCross.submitBounty(1, keccak256("test"));

        vm.stopPrank();
    }

    function testVerifyBounty_sucess() external {
        assertTrue(true);
    }

    /**************************************************************************
     *                                HELPERS                                 *
     *************************************************************************/

    function _depositWeth(address recipient, uint256 ethAmount) internal {
        // check that VB has no WETH balance
        uint256 wethBalance0 = IERC20(WETH).balanceOf(recipient);
        assertEq(wethBalance0, 0);

        // deposit ETH in recipient account
        vm.prank(recipient);
        MockWETH(WETH).deposit{value: ethAmount}();
    }

    function _quotePrice(address token0, address token1, uint256 amount) internal returns (uint256 amountOut) {
        amountOut = IQuoter(UNI_QUOTER).quoteExactInputSingle(
            token0,
            token1,
            3000,
            amount,
            0
        );
    }
}
