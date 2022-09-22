// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "forge-std/console.sol";
import "./Org.sol";

contract SBFactory is Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private orgId;

    Org[] public orgs;
    uint256 totalSupply;

    address usdcTokenAddress;
    address uniV3SwapRouterAddress;
    OrgRouter orgRouter;

    event orgCreated(address indexed orgAddress);

    constructor(
        address _uniswapV3SwapRouter,
        address _usdcTokenAddress
    ) {
        uniV3SwapRouterAddress = _uniswapV3SwapRouter;
        usdcTokenAddress = _usdcTokenAddress;
        orgRouter = new OrgRouter(uniV3SwapRouterAddress, usdcTokenAddress);
    }

    function createOrg(string memory _name) public {
        orgId.increment();
        Org newOrg = new Org(
            _name,
            msg.sender,
            orgId.current(),
            address(orgRouter),
            usdcTokenAddress
        );

        orgs.push(newOrg);
    }

    /**
     * @notice Returns the org address at the given index
     */
    function getOrgRouter() public view returns (address) {
        return address(orgRouter);
    }

    // function openBounty(uint _bountyId) public onlyOrgOwner(bountyIdToOrg[_bountyId]) {
    //     bounties[_bountyId].open();
    // }

    // function applyToBounty(uint _bountyId, uint _stakeAmount) public {
    //     bounties[_bountyId].applyTo(_stakeAmount);
    // }

    // // TODO: add a function to pass in bounty verify function
    // function verifyBounty(uint _bountyId) public onlyOrgOwner(bountyIdToOrg[_bountyId]) returns (bool){
    //     return bounties[_bountyId].verify();
    // }

    // function donateToBounty(uint _bountyId, uint256 amount) external {
    //     require(amount > 0, "ERROR: amount must be greater than 0");
    //     totalSupply = totalSupply + amount;
    //     // TODO: donate to bounty
    //     bounties[_bountyId].donate(amount);
    // }

    // donate to multiple bounties at once
}
