// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

/**
 * @title IManagedToken
 * @dev An interface for a contract that supports the management of user privileges.
 * Users can be assigned a set of privileges that determine whether they can send and/or receive tokens.
 */
interface IManagedToken {
    /**
     * @dev An event that is emitted when the privileges of an account are updated.
     * @param account The address of the account whose privileges were updated.
     * @param privileges The new privileges assigned to the account.
     */
    event UpdatePrivileges(address indexed account, bytes1 privileges);

    /**
     * @dev Updates the privileges of the specified account.
     * @param account The account whose privileges are being updated.
     * @param privileges The new privileges to assign to the account.
     */
    function updatePrivileges(address account, bytes1 privileges) external;
}
