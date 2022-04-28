// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "openzeppelin-contracts/contracts/security/ReentrancyGuard.sol";
import "openzeppelin-contracts/contracts/utils/Counters.sol";

import "./interface/IOrg.sol";
import "./specific-tasks/CustomBounty.sol";

contract KarmaMarketplace is ReentrancyGuard {
    mapping(uint => IOrg) public orgs; 
    mapping (uint => IBounty) public bounties;
    mapping (uint => uint) public bountyIdToOrg;

    using Counters for Counters.Counter;
    Counters.Counter private bountyId;
    Counters.Counter private orgId;

    modifier onlyOrgOwner(uint _orgId) {
        require(msg.sender == orgs[_orgId].owner(),"ERROR: not org owner");
        _;
    }
    function createOrg(string memory _name) public {
        orgId.increment();
        IOrg newOrg = new IOrg(orgId.current(), _name);
        orgs[orgId.current()] = newOrg;
    }

    function listBounty(uint _orgId, string memory _title, uint256 _reward, uint256 _deadline, uint256 _stakeReqd) public onlyOrgOwner(_orgId) {
        require(_reward > 0, "ERROR: reward must be greater than 0");
        CustomBounty newBounty = new CustomBounty(msg.sender, _title, _reward, _deadline);
        bountyId.increment();
        bounties[bountyId.current()] = newBounty;
        bountyIdToOrg[bountyId.current()] = _orgId;

    }

    function openBounty(uint _bountyId) public onlyOrg(bountyIdToOrg[_bountyId]) {
        bounties[_bountyId].open();
    }

    function applyToBounty(uint _bountyId) public {
        bounties[_bountyId].apply();
    }

    // TODO: add a function to pass in bounty verify function
    function verifyBounty(uint _bountyId) public onlyOrg(bountyIdToOrg[_bountyId]) {
        return bounties[_bountyId].verify();
    }
}