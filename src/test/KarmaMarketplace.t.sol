// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "ds-test/test.sol";
import "forge-std/console2.sol";
import "forge-std/Vm.sol";

import "../KarmaToken.sol";
import "../Treasury.sol";


contract ContractTest is DSTest {
    Vm private vm = Vm(HEVM_ADDRESS);
    address public deployer = 0xb4c79daB8f259C7Aee6E5b2Aa729821864227e84;

    Treasury public treasury;

    function setUp() public {
        treasury = new Treasury();
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
        
    }
}
