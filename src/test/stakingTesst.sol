pragma solidity 0.8.0; 

contract stakingTests {

1. function checkStake(uint _stakeAmount, uint _bountyId) {
    require(_stakeAmount >= bounties[_bountyId].stakeReqd(), "ERROR: not enough stake");
}
2. function checkBounty(uint _bountyId, uint _stakeAmount) {
    require(bounties[_bountyId].checkReward(_stakeAmount), "ERROR: stake does not go to correct bounty");
}
3. function checkDeadline(uint _bountyId) {
    require(bounties[_bountyId].deadline() > now, "ERROR: stake can't be accessed before deadline");
}
4. function checkAccess(uint _bountyId) {
    require(orgs[bountyIdToOrg[_bountyId]].owner() != msg.sender && msg.sender != bounties[_bountyId].staker() && msg.sender != tx.origin, "ERROR: neither org owner or staker or deployer can access the stake");
    
    
    }
