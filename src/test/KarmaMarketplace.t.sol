// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "ds-test/test.sol";
import "forge-std/console2.sol";
import "forge-std/Vm.sol";
import "forge-std/console.sol";

import {IOrg} from "../interface/IOrg.sol";
import {IBounty} from "../interface/IBounty.sol";
import {KarmaToken} from "../KarmaToken.sol";
import {CustomBounty} from "../specific-tasks/CustomBounty.sol";
import {Treasury} from "../Treasury.sol";
import {KarmaMarketplace} from "../KarmaMarketplace.sol";

contract ContractTest is DSTest {
    Vm private vm = Vm(HEVM_ADDRESS);
    address public deployer = 0xb4c79daB8f259C7Aee6E5b2Aa729821864227e84;

    Treasury public treasury = new Treasury();
    KarmaToken public token = new KarmaToken(100_000e18);
    KarmaMarketplace public marketplace = new KarmaMarketplace();

    function setUp() public {
        marketplace.createOrg("Celo");
    }

    function testExample() public {
        assertTrue(true);
    }

    function testBuyTokens() public {
        treasury.buyTokens{value: 1 ether}();
        assertEq(treasury.getBalance(deployer), 1e19);
        assertTrue(true);
    }

    function testCreatOrg() public {
        IOrg _celo = marketplace.orgs(1);
        assertEq(_celo.name(), "Celo");
        assertEq(_celo.owner(), deployer);
    }

    function testListBounty() public {
        marketplace.listBounty(1, "Eat Donut", 1, 2, 3);
        IBounty _sample = marketplace.bounties(1);
        assertEq(marketplace.bountyIdToOrg(1), 1);
        assertEq(_sample.title(), "Eat Donut");
    }

    function testCheckDeadline() public {
        marketplace.listBounty(1, "Eat Donut", 1, 1000000000, 0);
        IBounty _sample = marketplace.bounties(1);
        vm.warp(999999999);
        assertTrue(_sample.checkDeadline());
        vm.warp(1000000001);
        assertTrue(!_sample.checkDeadline());
    }

    function testOpenBounty() public {
        marketplace.listBounty(1, "Eat Donut", 1, 1000000000, 0);
        IBounty _sample = marketplace.bounties(1);
        assertTrue(!_sample.isOpen());
        _sample.open();
        assertTrue(_sample.isOpen());

        // marketplace.openBounty(1) does not work because caller is not the owner ( == deployer ). How to simulate this?
    }
}
