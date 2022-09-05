// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import "@openzeppelin/contracts/utils/Counters.sol";

import { AccessControl } from "./OrgAdmin.sol";
import { SwapRouter } from "./util/SwapRouter.sol";

contract Org is AccessControl {
    using Counters for Counters.Counter;
    struct Bounty {
        string title;
        uint256 stakeReqd;
        uint256 dontaions;
        uint256 deadline;
        bool open;
        address[] applicants;
    }

    string public name;
    mapping(uint256 => Bounty) public bounties;
    uint256 totalBounties;

    // TODO: config file for different chains
    address usdcTokenAddress = 0xe6b8a5CF854791412c1f6EFC7CAf629f5Df1c747;
    address uniV3SwapRouterAddress = 0xE592427A0AEce92De3Edee1F18E0157C05861564;

    Counters.Counter private bountyId;
    mapping(uint256 => mapping(address => uint256)) applicantStakes;
    mapping(uint256 => mapping(address => bool)) applicantVerified;

    SwapRouter public uniV3Router;

    event BountyCreated(uint256 indexed orgId, uint256 indexed bountyId, string title, uint256 deadline);

    constructor (
        string memory _name,
        address _deployer,
        uint256 _orgId
    ) AccessControl(_orgId, _deployer) public {
        name = _name;
        uniV3Router = new SwapRouter(uniV3SwapRouterAddress, usdcTokenAddress);
    }

    /**
     * @notice Creates a new bounty
     * @param _title Title of the bounty
     * @param _stakeReqd Amount of tokens required to apply to the bounty
     * @param _deadline Timestamp of the deadline for the bounty
     */
    function createBounty (
        string calldata _title,
        uint256 _stakeReqd,
        uint256 _deadline
    ) public onlyAdmin {
        require(_deadline > block.timestamp, "ERROR: deadline must be in the future");
        address[] memory emptyApps;
        Bounty memory newBounty = Bounty(_title,_stakeReqd, 0, _deadline, false, emptyApps);
        bountyId.increment();
        bounties[bountyId.current()] = newBounty;
        emit BountyCreated(orgId, bountyId.current(), _title, _deadline);
    }

    /**
     * @notice Opens a bounty for applicants
     * @param _bountyId Id of the bounty to open
     */
    function openBounty(uint256 _bountyId) public onlyAdmin {
        require(bounties[_bountyId].deadline > block.timestamp, "ERROR: deadline must be in the future");
        bounties[bountyId.current()].open = true;
    }

    /**
     * @notice Applies to a bounty
     * @param _bountyId Id of the bounty to apply to
     * @param _depositTokenAddress Address of the token to deposit
     * @param _amount Amount of tokens to stake
     */
    function donateToBounty (
        uint256 _bountyId,
        address _depositTokenAddress,
        uint256 _amount
    ) external {
        require(_amount > 0, "ERROR: amount must be greater than 0");
        require(bounties[_bountyId].open, "ERROR: bounty must be open");
        uniV3Router.setinputToken(_depositTokenAddress);

        bounties[_bountyId].dontaions = bounties[_bountyId].dontaions + _amount;
    }
}
