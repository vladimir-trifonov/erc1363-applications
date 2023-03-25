// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

/**
 * @title IRestrictedToken
 * @dev An interface for Solidity contracts that define restrictions on sending and receiving tokens for individual accounts.
 */
interface IRestrictedToken {

    /**
     * @dev Emitted when the restriction for an account are updated.
     * @param account The address of the account which restriction were updated.
     * @param restriction The new restriction assigned to the account.
     */
    event UpdateRestriction(address indexed account, bytes1 restriction);

    /**
     * @dev Updates the restriction for a given account.
     * @param account The address of the account which restriction are being updated.
     * @param restriction The new restriction to assign to the account.
     */
    function updateRestriction(address account, bytes1 restriction) external;
}
