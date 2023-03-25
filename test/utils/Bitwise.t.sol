// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "forge-std/Test.sol";
import "../../src/utils/Bitwise.sol";

contract TestBitwise is Test {
    /**
     * @dev Tests the `check` function of the Bitwise library.
     */
    function testCheckTrue() public {
        // Set up
        bytes1 src = 0x0F;
        bytes1 query = 0x03;

        // Call the function
        bool result = Bitwise.check(src, query);

        // Verify the effects
        assertTrue(result);
    }

    /**
     * @dev Tests the `check` function of the Bitwise library.
     */
    function testCheckFalse() public {
        // Set up
        bytes1 src = 0x0F;
        bytes1 query = 0x10;

        // Call the function
        bool result = Bitwise.check(src, query);

        // Verify the effects
        assertFalse(result);
    }
}
