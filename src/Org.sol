// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import "@openzeppelin/contracts/utils/Counters.sol";
import '@openzeppelin/contracts/token/ERC20/ERC20.sol';

import { AccessControl } from "./OrgAdmin.sol";
import { OrgRouter } from "./util/OrgRouter.sol";

import { USDC, VERIFY_PERIOD } from "./Constants.sol";

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

    enum AppStatus {
        NONE,
        APPLIED,
        VERIFIED,
        REJECTED
    }

    string public name;
    mapping(uint256 => Bounty) public bounties;
    uint256 totalBounties;

    address usdcTokenAddress;
    address orgRouterAddress;

    Counters.Counter private bountyId;
    mapping(uint256 => mapping(address => AppStatus)) public applicantStatus;
    mapping(uint256 => mapping(address => bytes32)) public submittedHashes;
    mapping(uint256 => mapping(address => uint256)) public donations;
    mapping(uint256 => uint256) public bountyPool;

    OrgRouter public orgRouter;

    event BountyCreated(uint256 indexed orgId, uint256 indexed bountyId, string title, uint256 deadline);

    constructor (
        string memory _name,
        address _deployer,
        uint256 _orgId,
        address _orgRouter,
        address usdc
    ) AccessControl(_orgId, _deployer) public {
        name = _name;
        config(_orgRouter, usdc);
    }

    /**************************************************************************
     * Modifiers
     *************************************************************************/

    modifier prelimChecks(uint256 _bountyId) {
        require(bounties[_bountyId].open, "ERROR: bounty must be open");
        require(bounties[_bountyId].deadline > block.timestamp, "ERROR: deadline passed");
        _;
    }

    /**************************************************************************
     * Core Functions
     *************************************************************************/


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

        bounties[_bountyId].open = true;
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
    ) prelimChecks(_bountyId) external {

        require(_amount > 0, "ERROR: amount must be greater than 0");

        orgRouter.setinputToken(_depositTokenAddress);
        uint256 amountOut = orgRouter.swapExactInputSingle(_amount, msg.sender);

        donations[_bountyId][msg.sender] += amountOut; // TODO: don't need this: give equal ERC20 cTokens
        bountyPool[_bountyId] += amountOut;
    }

    /**
     * @notice Applies to a bounty
     * @param _bountyId Id of the bounty to apply to
     * @param _stakeTokenAddress Address of the token applicant wants to stake
     * @param _maxAmountInStaked Max amount of tokens appliant wants to swap and stake
     */
    function applyToBounty (
        uint256 _bountyId,
        address _stakeTokenAddress,
        uint256 _maxAmountInStaked
    ) prelimChecks(_bountyId) external {

        require(msg.sender != admin(), "ERROR: admin cannot apply to own bounty");
        require(applicantStatus[_bountyId][msg.sender] == AppStatus.NONE, "ERROR: applicant already applied");

        orgRouter.setinputToken(_stakeTokenAddress);
        uint256 amountIn = orgRouter.swapExactOutputSingle(
            bounties[_bountyId].stakeReqd,
            _maxAmountInStaked,
            msg.sender
        );

        applicantStatus[_bountyId][msg.sender] = AppStatus.APPLIED;
        bounties[_bountyId].applicants.push(msg.sender);
        bountyPool[_bountyId] += amountIn;

    }

    /**
     * @notice applicant submits hash of their work
     * @param _bountyId Id of the bounty to apply to
     * @param _submissionHash bytes32 cast of the IPFS hash of the IPFS applicant's work
     * @dev IPFS hash cast from bytes58 -> bytes32 to store on-chain
     */
    function submitBounty (
        uint _bountyId,
        bytes32 _submissionHash
    ) prelimChecks(_bountyId) external {

        require(
            applicantStatus[_bountyId][msg.sender] == AppStatus.APPLIED, "ERROR: applicant must have applied"
        );

        submittedHashes[_bountyId][msg.sender] = _submissionHash;
    }

    /**
     * @notice Verifies an applicant's work
     * @param _bountyId Id of the bounty to apply to
     * @param _applicant Address of the applicant to verify
     * @param _verified bool is the org admin can verify the applicant's work
     */
    function verifyBounty (
        uint _bountyId,
        address _applicant,
        bool _verified
    ) prelimChecks(_bountyId) external onlyAdmin {

        require(
            applicantStatus[_bountyId][_applicant] == AppStatus.APPLIED, "ERROR: applicant must have applied"
        );

        require(
            submittedHashes[_bountyId][_applicant] != bytes32(0),
            "ERROR: applicant must have submitted"
        );

        applicantStatus[_bountyId][_applicant] = AppStatus(_verified ? 2 : 3);
    }

    /**
     * @notice Closes a bounty
     * @param _bountyId Id of the bounty to apply to
     */
    function closeBounty(uint256 _bountyId) public onlyAdmin {

        require(bounties[_bountyId].deadline > block.timestamp, "ERROR: deadline must be in the future");

        bounties[_bountyId].open = false;
    }

    /**
     * @notice Distributes rewards to verified and undecided applicants
     * @param _bountyId Id of the bounty to apply to
     */
    function distirbuteRewards(uint256 _bountyId) public {

        require(bounties[_bountyId].deadline + VERIFY_PERIOD < block.timestamp, "ERROR: verify period not over");

        uint256 numVerified = 0;
        AppStatus appState;

        address[] memory appPool = bounties[_bountyId].applicants;
        for (uint256 i = 0; i < appPool.length; i++) {
            appState = applicantStatus[_bountyId][appPool[i]];
            if (appState == AppStatus.VERIFIED || appState == AppStatus.APPLIED) {
                numVerified++;
            }
        }

        uint256 reward = bountyPool[_bountyId] / numVerified;

        for (uint256 i = 0; i < appPool.length; i++) {
            appState = applicantStatus[_bountyId][appPool[i]];
            if (appState == AppStatus.VERIFIED || appState == AppStatus.APPLIED) {
                ERC20(USDC).transfer(appPool[i], reward);
            }
        }
    }
}
