// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import "./helpers/BaseTest.sol";
import "forge-std/console2.sol";
import "forge-std/Vm.sol";
import "forge-std/console.sol";

import { Org } from "../Org.sol";
import { SBToken } from "../SBToken.sol";
import { SBFactory } from "../SBFactory.sol";

import { MockWETH } from "./helpers/MockWETH.sol";

import {
    WETH,
    USDC,
    UNI_ROUTER
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

        // _depositWeth(address(this), 1000);
        // _depositWeth(adele, 1000);
        // _depositWeth(bob, 1000);
    }

    function testCreatOrg() public {
        factory.createOrg("Celo");
        Org _celo = factory.orgs(3);

        assertEq(_celo.name(), "Celo");
        assertEq(_celo.admin(), deployer);
    }

    function testCreateBounty() public {

        Org redCross = factory.orgs(0);
        uint256 bountyDeadline = block.timestamp + 7 days;
        redCross.createBounty("Help the poor", 1e16, block.timestamp + 7 days);

        (
            string memory title,
            uint256 stakeReqd,
            uint256 deadline,
            bool open
        ) = redCross.bounties(1);

        assertEq(title, "Help the poor");
        assertEq(stakeReqd, 1e16);
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
        redCross.createBounty(
            "Help the poor",
            1e16,
            block.timestamp + 7 days
        );
        redCross.openBounty(1);

        ( , , , bool open ) = redCross.bounties(1);
        assertEq(open, true);
    }

    // function testDonate_USDC() public {
    //     Org redCross = factory.orgs(0);
    //     redCross.createBounty(
    //         "Help the poor",
    //         1e16,
    //         block.timestamp + 7 days
    //     );
    //     redCross.openBounty(1);
    //     vm.startPrank(adele);
    //     console.log("adele address: ", adele);
    //     console.log("org address: ", address(redCross));
    //     console.log("org router address: ", orgRouterAddress);
    //     (bool success, bytes memory result) = USDC.call(
    //         abi.encodeWithSignature(
    //             "approve(address,uint256)",
    //             orgRouterAddress,
    //             1000e6
    //         )
    //     );
    //     assertTrue(success);
    //     assertEq(ERC20(USDC).allowance(adele, address(redCross)), 1000e18);
    //     redCross.donateToBounty(1, USDC, 100e6);
    //     vm.stopPrank();

    //     ( uint256 amount ) = redCross.donations(1, adele);
    //     assertEq(amount, 100e6);
    // }

    function testDonate_WETH() public {
        Org redCross = factory.orgs(0);
        redCross.createBounty("Help the poor", 1e16, block.timestamp + 7 days);
        redCross.openBounty(1);

        vm.startPrank(adele);
        (bool success, bytes memory result) = WETH.call(
            abi.encodeWithSignature(
                "approve(address,uint256)",
                orgRouterAddress,
                1000e18
            )
        );
        assertTrue(success);

        assertEq(ERC20(WETH).allowance(adele, orgRouterAddress), 1000e18);
        console.log("allowance: ", ERC20(WETH).allowance(adele, orgRouterAddress));
        redCross.donateToBounty(1, WETH, 1e18);
        vm.stopPrank();

        ( uint256 amount ) = redCross.donations(1, adele);
        assertTrue(amount > 1e6);
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
}
