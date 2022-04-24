// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "openzeppelin-contracts/contracts/access/Ownable.sol";
import "./KarmaToken.sol";

contract Treasury is Ownable {
    // TODO: bonding/staking

    KarmaToken karma;
    uint256 tokensPerEth = 10;

    event BuyTokens(address buyer, uint256 amountOfETH, uint256 amountOfTokens);
    event SellTokens(
        address seller,
        uint256 amountOfETH,
        uint256 amountOfTokens
    );

    // contructor lets owner mint token
    constructor() public {
        // supply 100 * 10 ** 18
        // 1000000000000000000
        // karma = KarmaToken(tokenAddress);
        karma = new KarmaToken(1e21);

    }

    function getBalance(address q) public view returns (uint256) {
        return karma.balanceOf(q);
    }

    // buy tokens from tresure
    function buyTokens() public payable {
        require(msg.value > 0, "Need greater than 0");
        uint256 tokensBuy = tokensPerEth * msg.value;
        // console.log(tokensBuy);

        // check if vendor has enough tokens
        uint256 vendorBal = karma.balanceOf(address(this));
        require(vendorBal >= tokensBuy, "insufficent tokens to purchase");

        // // Transfer token to the msg.sender
        bool sent = karma.transfer(msg.sender, tokensBuy);
        require(sent, "Failed to transfer token to user");

        emit BuyTokens(msg.sender, msg.value, tokensBuy);
    }

    // sell token back to treasury
    function sellTokens(uint256 amt) public {
        require(amt > 0, "Amount should be greater than 0");
        require(
            karma.balanceOf(msg.sender) >= amt,
            "You don't have enough tokens"
        );

        uint256 amtInEth = amt / tokensPerEth;
        require(
            address(this).balance >= amtInEth,
            "Vendor has not enough funds to accept the sell request"
        );

        // required to approve token first

        bool sent = karma.transferFrom(msg.sender, address(this), amt);
        require(sent, "Failed to transfer tokens from user to vendor");

        (sent, ) = msg.sender.call{value: amtInEth}("");
        require(sent, "Failed to send ETH to the user");

        emit SellTokens(msg.sender, amtInEth, amt);
    }

    //basic contract functions added:
    //function to transfer tokens upon validating completion of a task
    // function _transfer(address a) public {
    //     require(balanceOf(_msgSender()) > msg.value());
    //     balanceOf(_msgSender()) = balanceOf(_msgSender()) - msg.value();
    //     balanceOf(a) = balanceOf(a) + msg.value();
    // }

    // hold tokens - not sure if I should put here
    //based on assumption that collatoral for the task si same for the user and task giver
    // function holdTokens(ITask task) public {
    //     //check token balence
    //     uint256 bal = krmToken.balanceOf(_msgSender());
    //     require(vendorBal >= task.collatoral, "insufficent tokens to purchase");
    //     krmToken.balanceOf(_msgSender()) = bal - task.collatoral;
    //     task.userApproved[_msgSender()] = true;
    // }

    // function payOutTokens(ITask task, address user) {
    //     krmToken.balanceOf(_msgSender()) = bal + task.collatoral;
    //     task.userApproved[_msgSender()] = false;
    // }
}