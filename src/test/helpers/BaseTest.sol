// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.15;

import "forge-std/Test.sol";

contract BaseTest is Test
{
    address payable internal adele  = payable(_makeAddress("adele"));
    address payable internal bob    = payable(_makeAddress("bob"));
    address payable internal chester    = payable(_makeAddress("chester"));
    address payable internal dua    = payable(_makeAddress("dua"));
    address payable internal eminem   = payable(_makeAddress("eminem"));
    address payable internal freddie   = payable(_makeAddress("freddie"));

    function _makeAddress(string memory aName) internal returns (address)
    {
        address lAddress = address(
            uint160(uint256(
                keccak256(abi.encodePacked(aName))
            ))
        );
        vm.label(lAddress, aName);

        return lAddress;
    }
}
