// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import "./helpers/BaseTest.sol";
import "forge-std/console2.sol";
import "forge-std/Vm.sol";
import "forge-std/console.sol";

import { Org } from "../Org.sol";
import { SBToken } from "../SBToken.sol";
import { SBFactory } from "../SBFactory.sol";

import '@openzeppelin/contracts/token/ERC20/ERC20.sol';


contract SBFactoryTest is BaseTest {
    // Vm private vm = Vm(HEVM_ADDRESS);
    uint256 mainnetFork;
    string MAINNET_RPC_URL = vm.envString("MAINNET_RPC_URL");

    address internal deployer = 0xb4c79daB8f259C7Aee6E5b2Aa729821864227e84;

    address internal usdcAddress = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address internal uniTokenAddress = 0x1f9840a85d5aF5bf1D1762F925BDADdC4201F984;

    address internal uniswapV3SwapRouter = 	0xE592427A0AEce92De3Edee1F18E0157C05861564;
    address internal orgRouterAddress;
    SBFactory internal factory;


    function setUp() public {
        factory = new SBFactory(uniswapV3SwapRouter, usdcAddress);
        orgRouterAddress = factory.getOrgRouter();

        factory.createOrg("RedCross");
        factory.createOrg("Gitcoin");
        factory.createOrg("WorldCoin");
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

    function testDonate_USDC() public {
        Org redCross = factory.orgs(0);
        redCross.createBounty(
            "Help the poor",
            1e16,
            block.timestamp + 7 days
        );
        redCross.openBounty(1);
        vm.startPrank(adele);
        console.log("adele address: ", adele);
        console.log("org address: ", address(redCross));
        console.log("org router address: ", orgRouterAddress);
        (bool success, bytes memory result) = usdcAddress.call(
            abi.encodeWithSignature(
                "approve(address,uint256)",
                orgRouterAddress,
                1000e6
            )
        );
        assertTrue(success);
        assertEq(ERC20(usdcAddress).allowance(adele, address(redCross)), 1000e18);
        redCross.donateToBounty(1, usdcAddress, 100e6);
        vm.stopPrank();

        ( uint256 amount ) = redCross.donations(1, adele);
        assertEq(amount, 100e6);
    }

    // function testDonate_18decimal() public {
    //     Org redCross = factory.orgs(0);
    //     redCross.createBounty("Help the poor", 1e16, block.timestamp + 7 days);
    //     redCross.openBounty(1);

    //     vm.prank(adele);
    //     redCross.donateToBounty(1, uniTokenAddress, 1000e18);

    //     ( uint256 amount ) = redCross.donations(1, adele);
    //     assertEq(amount, 100e18);
    // }
}
