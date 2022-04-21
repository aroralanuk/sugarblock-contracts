// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../interface/IBounty.sol";

contract CustomBounty is IBounty {
    Bounty newBounty;
    constructor(address _owner, string _title, uint256 _reward, uint256 _deadline) public {
        newBounty = new Bounty({ 
            bType: BountyType.Custom,
            title: _title, 
            reward: _reward, 
            deadline: _deadline
        });
    }
}
