// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import "@openzeppelin/utils/Counters.sol";

import "./interface/IOrg.sol";
import "./Bounty.sol";

contract SBFactory {
    mapping(uint => IOrg) public orgs;
    mapping (uint => IBounty) public bounties;
    mapping (uint => uint) public bountyIdToOrg;

    using Counters for Counters.Counter;
    Counters.Counter private bountyId;
    Counters.Counter private orgId;

    uint256 totalSupply;

    modifier onlyOrgOwner(uint _orgId) {
        require(msg.sender == orgs[_orgId].owner(),"ERROR: not org owner");
        _;
    }

    function createOrg(string memory _name) public {
        orgId.increment();
        IOrg newOrg = new IOrg(_name, msg.sender);
        orgs[orgId.current()] = newOrg;
    }

    function listBounty(uint _orgId, string memory _title, uint256 _reward, uint256 _deadline, uint256 _stakeReqd) public onlyOrgOwner(_orgId) {
        require(_reward > 0, "ERROR: reward must be greater than 0");
        CustomBounty newBounty = new CustomBounty(msg.sender, _title, _reward, _deadline);
        bountyId.increment();
        bounties[bountyId.current()] = newBounty;
        bountyIdToOrg[bountyId.current()] = _orgId;

    }

    function openBounty(uint _bountyId) public onlyOrgOwner(bountyIdToOrg[_bountyId]) {
        bounties[_bountyId].open();
    }

    function applyToBounty(uint _bountyId, uint _stakeAmount) public {
        bounties[_bountyId].applyTo(_stakeAmount);
    }

    // TODO: add a function to pass in bounty verify function
    function verifyBounty(uint _bountyId) public onlyOrgOwner(bountyIdToOrg[_bountyId]) returns (bool){
        return bounties[_bountyId].verify();
    }

    function donateToBounty(uint _bountyId, uint256 amount) external {
        require(amount > 0, "ERROR: amount must be greater than 0");
        totalSupply = totalSupply + amount;
        // TODO: donate to bounty
        bounties[_bountyId].donate(amount);
    }

    // donate to multiple bounties at once
}
