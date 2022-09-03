// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

/**
 * @dev Contract module which provides access control mechanism for each Org
 * similar to Openzeppelin's Owanble contact
 *
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyAdmin`, which can be applied to your functions to restrict their use to
 * the admin.
 */
abstract contract OrgAdmin {
    uint256 public orgId;
    bool private _paused;
    address private _admin;

    event AdminContolTransferred(address indexed previousAdmin, address indexed newAdmin);
    event OrgPaused(uint256 indexed _orgId, address indexed _admin);
    event OrgUnpaused(uint256 indexed _orgId, address indexed _admin);

    /**
     * @dev Initializes the contract setting the org deployer as the initial admin and org Id
     */
    constructor(uint256 _orgId, address orgDeloyer) {
        orgId = _orgId;
        _paused = false;
        _transferAdmin(orgDeloyer);
    }

    /**
     * @dev Throws if called by any account other than the admin.
     */
    modifier onlyAdmin() {
        _checkAdmin();
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     */
    modifier whenNotPaused() {
        _requireNotPaused();
        _;
    }

    /**
     * @dev Returns the address of the current admin.
     */
    function admin() public view virtual returns (address) {
        return _admin;
    }

    /**
     * @dev Throws if the sender is not the admin.
     */
    function _checkAdmin() internal view virtual {
        require(admin() == msg.sender, "Ownable: caller is not the admin");
    }

    /**
     * @dev Leaves the contract without admin. It will not be possible to call
     * `onlyAdmin` functions anymore. Can only be called by the current admin.
     *
     * NOTE: Renouncing admin will leave the contract without an admin,
     * thereby removing any functionality that is only available to the admin.
     */
    function renounceAdmin() public virtual onlyAdmin {
        _transferAdmin(address(0));
    }

    /**
     * @dev Transfers admin of the contract to a new account (`newAdmin`).
     * Can only be called by the current admin.
     */
    function transferAdmin(address newAdmin) public virtual onlyAdmin whenNotPaused {
        require(newOwner != address(0), "Ownable: new admin is the zero address");
        _transferAdmin(newAdmin);
    }

    /**
     * @dev Transfers admin functionality of the contract to a new account (`newAdmin`).
     * Internal function without access restriction.
     */
    function _transferAdmin(address newAdmin) internal virtual {
        address oldAdmin = _admin;
        _admin = newAdmin;
        emit aDMINTransferred(oldAdmin, newAdmin);
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Throws if the contract is paused.
     */
    function _requireNotPaused() internal view virtual {
        require(!paused(), "Pausable: paused");
    }

    /**
     * @dev Triggers stopped state. Can only be called by the current admin.
     */
    function _pause() external virtual whenNotPaused onlyAdmin {
        _paused = true;
        emit Paused(orgId, _owner);
    }

    /**
     * @dev Returns to normal state. Can only be called by the current admin.
     */
    function _unpause() external virtual whenPaused onlyAdmin {
        _paused = false;
        emit Unpaused(orgId, _owner);
    }

}
