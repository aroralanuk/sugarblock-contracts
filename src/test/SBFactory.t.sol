// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import "./helpers/BaseTest.sol";
import "forge-std/console2.sol";
import "forge-std/Vm.sol";
import "forge-std/console.sol";

import { Org } from "../Org.sol";
import { SBToken } from "../SBToken.sol";
import { SBFactory } from "../SBFactory.sol";


contract SBFactoryTest is BaseTest {
    // Vm private vm = Vm(HEVM_ADDRESS);
    address public deployer = 0xb4c79daB8f259C7Aee6E5b2Aa729821864227e84;

    SBFactory public factory = new SBFactory();

    function setUp() public {
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
        ( string memory title, uint256 stakeReqd, uint256 deadline, bool open ) = redCross.bounties(1);
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

    function testOpenBounty() public {
        Org redCross = factory.orgs(0);
        redCross.createBounty("Help the poor", 1e16, block.timestamp + 7 days);
        redCross.openBounty(1);
        ( , , , bool open ) = redCross.bounties(1);
        assertEq(open, true);
    }
}
