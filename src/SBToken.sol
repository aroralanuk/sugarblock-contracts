// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import "openzeppelin-contracts/contracts/access/AccessControl.sol";

contract KarmaToken is ERC20, AccessControl {
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

    constructor(uint256 initSupply) ERC20("Karma", "KRM") {
        _mint(msg.sender, initSupply);
        _setupRole(ADMIN_ROLE, msg.sender);
        // _setupRole(ADMIN_ROLE, admin);
    }

    // function validate(
    //     address org,
    //     address acceptor,
    //     uint256 amount
    // ) public {
    //     // Check that the calling account has the minter role
    //     require(hasRole(ADMIN_ROLE, _msgSender()), "Caller is not an admin");
    //     _transfer(org, acceptor, amount);
    // }
}