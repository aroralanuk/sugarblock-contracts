// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../interface/IBounty.sol";

contract CustomBounty is IBounty {
    // constructor(address _owner, string memory _title, uint256 _reward, uint256 _deadline) public {
    //     owner = _owner;
    //     bType = BountyType.Custom;
    //     title = _title;
    //     reward = _reward; 
    //     deadline= _deadline;
    // }

    constructor(address _owner, string memory _title, uint256 _reward, uint256 _deadline) 
        IBounty(BountyType.Custom, _owner, _title, _reward, _deadline) public {}
}
