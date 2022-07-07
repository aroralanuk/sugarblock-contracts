// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "ds-test/test.sol";
import "forge-std/console2.sol";
import "forge-std/Vm.sol";
import "forge-std/console.sol";

import { IOrg } from "../interface/IOrg.sol";
import { KarmaToken} from "../KarmaToken.sol";
import { Treasury } from "../Treasury.sol";
import { KarmaMarketplace } from "../KarmaMarketplace.sol";


contract ContractTest is DSTest {
    Vm private vm = Vm(HEVM_ADDRESS);
    address public deployer = 0xb4c79daB8f259C7Aee6E5b2Aa729821864227e84;

    Treasury public treasury = new Treasury();
    KarmaToken public token = new KarmaToken(100_000e18);
    KarmaMarketplace public marketplace = new KarmaMarketplace();

    function setUp() public {

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
        marketplace.createOrg("Celo");
        IOrg _celo = marketplace.orgs(1);
        
        assertEq(_celo.name(), "Celo");
        assertEq(_celo.owner(), deployer);
    }
}
