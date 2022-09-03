// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import "@openzeppelin/contracts/utils/Counters.sol";

import { AccessControl } from "./OrgAdmin.sol";

contract Org is AccessControl {
    using Counters for Counters.Counter;
    struct Bounty {
        string title;
        uint256 stakeReqd;
        uint256 deadline;
        bool open;
        address[] applicants;
    }

    string public name;
    mapping(uint256 => Bounty) public bounties;
    uint256 totalBounties;

    Counters.Counter private bountyId;
    mapping(uint256 => mapping(address => uint256)) applicantStakes;
    mapping(uint256 => mapping(address => bool)) applicantVerified;

    event BountyCreated(uint256 indexed orgId, uint256 indexed bountyId, string title, uint256 deadline);

    constructor(string memory _name, address _deployer, uint256 _orgId) AccessControl(_orgId, _deployer) public {
        name = _name;
    }

    function createBounty(string calldata _title, uint256 _stakeReqd, uint256 _deadline) public onlyAdmin {
        require(_deadline > block.timestamp, "ERROR: deadline must be in the future");
        address[] memory emptyApps;
        Bounty memory newBounty = Bounty(_title,_stakeReqd, _deadline, false, emptyApps);
        bountyId.increment();
        bounties[bountyId.current()] = newBounty;
        emit BountyCreated(orgId, bountyId.current(), _title, _deadline);
    }

    function openBounty(uint256 _bountyId) public onlyAdmin {
        require(bounties[_bountyId].deadline > block.timestamp, "ERROR: deadline must be in the future");
        bounties[bountyId.current()].open = true;
    }
}
