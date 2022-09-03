// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "ds-test/test.sol";
import "forge-std/console2.sol";
import "forge-std/Vm.sol";
import "forge-std/console.sol";

import { Org } from "../IOrg.sol";
import { SBToken } from "../SBToken.sol";
import { Treasury } from "../Treasury.sol";
import { SBFactory } from "../SBFactory.sol";


contract SBFactory is DSTest {
    Vm private vm = Vm(HEVM_ADDRESS);
    address public deployer = 0xb4c79daB8f259C7Aee6E5b2Aa729821864227e84;

    Treasury public treasury = new Treasury();
    SBFactory public factory = new SBFactory();

    function setUp() public {

    }

    function testCreatOrg() public {
        marketplace.createOrg("Celo");
        IOrg _celo = marketplace.orgs(1);

        assertEq(_celo.name(), "Celo");
        assertEq(_celo.owner(), deployer);
    }

    function testOrgAccess() public {

    }
}
