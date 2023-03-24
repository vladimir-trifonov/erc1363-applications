// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

/**
 * @title Bitwise
 * @dev A library that provides bitwise operations on bytes values.
 */
library Bitwise {
    /**
     * @dev Checks whether a specified bit is set to 1 in a bytes1 value.
     * @param src The bytes1 value to check.
     * @param query The bit to check (must be set to 1).
     * @return A boolean value indicating whether the specified bit is set to 1.
     */
    function check1(bytes1 src, bytes1 query) internal pure returns (bool) {
        return (src & query) == query;
    }
}

