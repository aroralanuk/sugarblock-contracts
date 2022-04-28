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
    bool isOpen;
    uint256 stakeReqd;
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

     // function verify() public virtual returns (bool);
    function checkDeadline() public view returns (bool){
        return block.timestamp < deadline;
    }


    function open() public {
        require(msg.sender == owner, "ERROR: not owner");
        require(deadline > now, "ERROR: deadline has passed");
        isOpen = true;
    }

    function stake () public {
        require(isOpen, "ERROR: bounty is not open");
        require(_stake > 0, "ERROR: stake must be greater than 0");
    }


    function apply() public {
        require(isOpen, "ERROR: bounty is not open");
        require(msg.sender != owner, "ERROR: cannot apply to own bounty");
        require(checkDeadline(), "ERROR: deadline has passed");
        require(completions[msg.sender] == 0, "ERROR: already applied");
        usersApplied.push(msg.sender);
        userApproved[msg.sender] = false;
    }


    // function stake() public payable virtual ();
    // function accept() public virtual ();
    // function complete() public virtual returns (bool);
    // function giveReward() public virtual payable returns (bool);
}