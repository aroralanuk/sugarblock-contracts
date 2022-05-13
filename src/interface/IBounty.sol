// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

abstract contract IBounty {
    address public tokenAddress;

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
    mapping (address => bool) stakes;
    mapping (address => uint256) donations;
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

     function setTokenAddress(address _tokenAddress) external {
        tokenAddress = _tokenAddress;
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

    function stake (uint256 _tokenAmount) public {
        require(isOpen, "ERROR: bounty is not open");
        require(checkDeadline(), "ERROR: deadline has passed");
        require(_tokenAmount >= _stake, "ERROR: not enough stake");
        require(!stakes[msg.sender], "ERROR: already staked");

        
        IERC20(_tokenAddress).approve(address(this), _tokenAmount);    // TODO: set approve only first time
        IERC20(_tokenAddress).transferFrom(msg.sender, address(this), amount);
        stakes[msg.sender] = true;

    }


    function stakedAlready() public view returns (bool) {
        return stakes[msg.sender];
    }

    function donate (uint256 _tokenAmount) public {
        require(isOpen, "ERROR: bounty is not open");
        require(checkDeadline(), "ERROR: deadline has passed");

        IERC20(_tokenAddress).approve(address(this), _tokenAmount);    // TODO: set approve only first time
        IERC20(_tokenAddress).transferFrom(msg.sender, address(this), amount);
        donations[msg.sender] = donations[msg.sender] + _tokenAmount;
    }


    function apply(uint256 _stakeAmount)  public {
        require(isOpen, "ERROR: bounty is not open");
        require(msg.sender != owner, "ERROR: cannot apply to own bounty");
        require(checkDeadline(), "ERROR: deadline has passed");
        require(completions[msg.sender] == 0, "ERROR: already applied");

        stake(_stakeAmount);
        require(stakedAlready(), "ERROR: must stake before applying");
        usersApplied.push(msg.sender);
        userApproved[msg.sender] = false;
    }


    // function stake() public payable virtual ();
    // function accept() public virtual ();
    // function complete() public virtual returns (bool);
    // function giveReward() public virtual payable returns (bool);
}