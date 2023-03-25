// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

/**
 * @title Bitwise
 * @dev A Solidity library that provides utility functions for bitwise operations.
 */
library Bitwise {

    /**
     * @dev Checks if a bitwise query is satisfied by a test value.
     * @param src The test value to check.
     * @param query The bitwise query to check against.
     * @return A boolean indicating whether the query is satisfied by the test value.
     */
    function check(bytes1 src, bytes1 query) internal pure returns (bool) {
        return (src & query) == query;
    }
}
