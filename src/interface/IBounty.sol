// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

abstract contract IBounty {

    enum BountyType {
        Referral,
        Survey,
        Custom
    }

    struct Bounty {
        BountyType bType;
        string title;
        string description;
        uint256 reward;
        address client;
        uint256 deadline;
        mapping (address => uint8) completions;
        //idk if this is useful
        uint256 collateral;
        mapping ( address => bool) userApproved;
        
    }

    function verify() public virtual returns (bool);
    function checkDeadline() public virtual view returns (bool);
    // function stake() public payable virtual ();
    // function accept() public virtual ();
    function complete() public virtual returns (bool);
    function reward() public virtual payable returns (bool);
}