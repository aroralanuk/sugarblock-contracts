// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

abstract contract IBounty {

    enum BountyType {
        Referral,
        Survey,
        Custom
    }

    BountyType bType;
    address owner;
    string title;
    string description;
    uint256 reward;
    uint256 deadline;
    uint256[] usersApplied;
    // uint256 stake;
    mapping (address => uint8) completions;
    mapping ( address => bool) userApproved;

     constructor(BountyType _daType, address _owner, string memory _title, uint256 _reward, uint256 _deadline)  {
        bType =  _daType;
        owner = _owner;
        bType = BountyType.Custom;
        title = _title;
        reward = _reward; 
        deadline= _deadline;
     }


    function open() public {

    }


    // function verify() public virtual returns (bool);
    function checkDeadline() public view returns (bool){
        return block.timestamp < deadline;
    }
    // function stake() public payable virtual ();
    // function accept() public virtual ();
    // function complete() public virtual returns (bool);
    // function giveReward() public virtual payable returns (bool);
}