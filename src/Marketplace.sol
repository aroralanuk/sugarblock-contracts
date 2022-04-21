// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "openzeppelin-contracts/contracts/security/ReentrancyGuard.sol";
import "openzeppelin-contracts/contracts/utils/Counters.sol";

import "./interface/IOrg.sol";
import "./specific-tasks/CustomBounty.sol";

contract KarmaMarketplace is ReentrancyGuard {
    Org[] public orgs;
    mapping (uint => IBounty) public bounties;
    mapping (uint => uint) public bountyIdToOrg;

    using Counters for Counter.Counter;
    Counters.Counter private _bountyId;

    modifier onlyOrgOwner(uint _orgId) {
        require(msg.sender == orgs[_orgId].owner,"ERROR: not org owner");
        _;
    }
    function createOrg(string _name) public {
        orgs.push(new IOrg(msg.sender, _name));
    }

    function listBounty (uint _orgId, string _title, uint256 _reward, uint256 _deadline, ) public onlyOrg(_orgId) {
        require(_reward > 0, "ERROR: reward must be greater than 0");
        newBounty = new CustomBounty({ title: _title, reward: _reward, deadline: _deadline});
        bounties[id] = newBounty;
        bountyIdToOrg[id] = msg.sender;
    }

    // function openBounty(uint _bountyId) public onlyOrg(bountyIdToOrg[_bountyId]) {
    //     bounties[_bountyId].open();
    // }
}