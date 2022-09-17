// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import "@openzeppelin/contracts/utils/Counters.sol";

import { AccessControl } from "./OrgAdmin.sol";
import { OrgRouter } from "./util/OrgRouter.sol";

import "forge-std/console.sol";

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

    address usdcTokenAddress;
    address orgRouterAddress;

    Counters.Counter private bountyId;
    mapping(uint256 => mapping(address => uint256)) public applicantStakes;
    mapping(uint256 => mapping(address => bool)) public applicantVerified;
    mapping(uint256 => mapping(address => uint256)) public donations;

    OrgRouter public orgRouter;

    event BountyCreated(uint256 indexed orgId, uint256 indexed bountyId, string title, uint256 deadline);

    constructor (
        string memory _name,
        address _deployer,
        uint256 _orgId,
        address orgRouter,
        address usdc
    ) AccessControl(_orgId, _deployer) public {
        name = _name;
        config(orgRouter, usdc);
    }

    /**
     * @dev Configures the swap router and usdc token address
     */
    function config(
        address _orgRouterAddress,
        address _usdcTokenAddress
    ) internal {
        orgRouterAddress = _orgRouterAddress;
        usdcTokenAddress = _usdcTokenAddress;
        orgRouter = OrgRouter(_orgRouterAddress);
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
        Bounty memory newBounty = Bounty(_title,_stakeReqd, _deadline, false, emptyApps);
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
        require(bounties[_bountyId].deadline > block.timestamp, "ERROR: deadline must be in the future");

        orgRouter.setinputToken(_depositTokenAddress);
        uint256 amountOut = orgRouter.swapExactInputSingle(_amount, msg.sender);
        donations[_bountyId][msg.sender] += amountOut;
    }
}
