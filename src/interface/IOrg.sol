// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IBounty.sol";

contract IOrg {
    uint256 id;
    address owner;
    string name;



    // abstract function proof
    // referral.sol, proof using a mapping from referral code to user and check it for 5

    // function createTask(TaskType _type, string title)

    function listBounty (string _title, uint256 _reward, uint256 _deadline) public payable {
        newBounty = new Bounty({ title: _title, reward: _reward, deadline: _deadline});
        OrgBounties.push(newBounty);
    }   

    


}