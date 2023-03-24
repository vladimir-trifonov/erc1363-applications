// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "erc1363-payable-token/contracts/token/ERC1363/ERC1363.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./IManagedToken.sol";
import "./utils/Bitwise.sol";

/**
 * @title ManagedToken
 * @dev A contract that implements the ERC1363 token standard and adds support for managing user privileges.
 * Users can be assigned a set of privileges that determine whether they can send and/or receive tokens.
 */
contract ManagedToken is ERC1363, IManagedToken, Ownable {
    bytes1 public immutable SYSTEM_PRIVILEGES = 0x01;
    bytes1 public immutable REQUIRED_PRIVILEGES_SEND = 0x02;
    bytes1 public immutable REQUIRED_PRIVILEGES_RECEIVE = 0x04;
    bytes1 public immutable DEFAULT_PRIVILEGES = 0x07;

    mapping(address => bytes1) public privileges;

    /**
     * @dev Creates a new ManagedToken instance with the specified name, symbol, and initial supply.
     * The contract owner is set to the account that deploys the contract.
     * @param name The name of the token.
     * @param symbol The symbol of the token.
     * @param initialSupply The initial supply of the token.
     */
    constructor(
        string memory name,
        string memory symbol,
        uint256 initialSupply
    ) Ownable() ERC20(name, symbol) {
        _mint(msg.sender, initialSupply);
    }

    /**
     * @dev Returns true if the contract implements the specified interface, or false otherwise.
     * @param interfaceId The interface ID to check.
     * @return A boolean value indicating whether the contract implements the specified interface.
     */
    function supportsInterface(
        bytes4 interfaceId
    ) external view override returns (bool) {
        return
            interfaceId == type(IManagedToken).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /**
     * @dev Updates the privileges of the specified account.
     * Only the contract owner can call this function.
     * The new privileges cannot have an unset zero bit.
     * The account address must not be the zero address.
     * Calls the internal `_updatePrivileges` function to update the account privileges.
     * @param account The account whose privileges are being updated.
     * @param privileges The new privileges to assign to the account.
     */
    function updatePrivileges(
        address account,
        bytes1 privileges
    ) external onlyOwner {
        require(
            check1(privileges, SYSTEM_PRIVILEGES),
            "ManagedToken: privileges zero bit cannot be 0"
        );
        require(
            account != address(0),
            "ManagedToken: account is the zero address"
        );

        _updatePrivileges(account, privileges);
    }

    /**
     * @dev Internal function that updates the privileges of the specified account.
     * If the new privileges are the same as the default privileges, the account's privileges are removed.
     * Otherwise, the new privileges are assigned to the account.
     * Emits an `UpdatePrivileges` event with the updated account privileges.
     * @param account The account whose privileges are being updated.
     * @param privileges The new privileges to assign to the account.
     */
    function _updatePrivileges(address account, bytes1 privileges) internal {
        if (privileges == DEFAULT_PRIVILEGES) {
            delete privileges[account];
        } else {
            addressesPrivileges[account] = privileges;
        }

        emit UpdatePrivileges(account, privileges);
    }

    /**
     * @dev Hook function that is called before a token transfer occurs.
     * Checks whether the sender and recipient have the required privileges to send and receive tokens.
     * @param from The address that is transferring tokens.
     * @param to The address that is receiving tokens.
     * @param amount The amount of tokens being transferred.
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        require(
            from == address(0) ||
                Bitwise.check1(
                    _accountPrivileges(from),
                    REQUIRED_PRIVILEGES_SEND
                ),
            "ManagedToken: not enought privileges to send"
        );
        require(
            to == address(0) ||
                Bitwise.check1(
                    _accountPrivileges(to),
                    REQUIRED_PRIVILEGES_RECEIVE
                ),
            "ManagedToken: not enought privileges to receive"
        );
    }

    /**
     * @dev Internal function that returns the privileges of the specified account.
     * If no privileges have been assigned to the account, the default privileges are returned.
     * @param account The account whose privileges are being queried.
     * @return A bytes1 value representing the account's privileges.
     */
    function _accountPrivileges(address account) internal returns (bytes1) {
        return _privileges[account] || DEFAULT_PRIVILEGES;
    }
}
