// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "forge-std/Test.sol";
import "../src/RestrictedToken.sol";

/**
 * @title TestRestrictedToken
 * @dev A contract for testing the RestrictedToken contract.
 */
contract TestRestrictedToken is Test {

    RestrictedToken restrictedToken;

    /**
     * @dev Initializes the test environment by deploying a new instance of the RestrictedToken contract.
     */
    function setUp() public {
        restrictedToken = new RestrictedToken("Restricted Token", "RTK", 1000);
    }

    /**
     * @dev Tests the `updateRestriction` function of the RestrictedToken contract.
     */
    function testUpdateRestrictions() public {
        // Set up
        address account = address(0x123);
        bytes1 restriction = restrictedToken.RESTRICTION_SEND();

        // Call the function
        restrictedToken.updateRestriction(account, restriction);

        // Verify the effects
        assertEq(restrictedToken.restrictions(account), restriction);
    }

    /**
     * @dev Tests the `updateRestriction` function of the RestrictedToken contract with the zero address.
     */
    function testUpdateRestrictionsForZeroAddress() public {
        // Set up
        address account = address(0);
        bytes1 restriction = restrictedToken.RESTRICTION_SEND();

        // Call the function
        (bool success, ) = address(restrictedToken).call(abi.encodeWithSignature("updateRestriction(address,bytes1)", account, restriction));

        // Verify the effects
        assertFalse(success);
        assertTrue(restrictedToken.restrictions(account) != restriction);
    }

    /**
     * @dev Tests the default restriction of the RestrictedToken contract.
     */
    function testDefaultRestrictions() public {
        // Set up
        address account = address(0x123);

        // Verify the effects
        assertEq(restrictedToken.restrictions(account), 0);
    }

    /**
     * @dev Tests transferring tokens with a "send" restriction.
     */
    function testTransferWithRestrictionSend() public {
        // Set up
        address from = address(0x123);
        address to = address(0x456);
        uint256 amount = 100;
        restrictedToken.transfer(from, amount);
        restrictedToken.updateRestriction(from, restrictedToken.RESTRICTION_SEND());

        vm.prank(from);
        // Call the function
        (bool success, ) = address(restrictedToken).call(abi.encodeWithSignature("transfer(address,uint256)", to, amount));
        
        // Verify the effects
        assertFalse(success);
    }

    /**
     * @dev Tests transferring tokens with a "receive" restriction.
     */
    function testTransferWithRestrictionReceive() public {
        // Set up
        address from = address(0x123);
        address to = address(0x123);
        uint256 amount = 100;
        restrictedToken.transfer(from, amount);
        restrictedToken.updateRestriction(to, restrictedToken.RESTRICTION_RECEIVE());

        vm.prank(from);
        // Call the function
        (bool success, ) = address(restrictedToken).call(abi.encodeWithSignature("transfer(address,uint256)", to, amount));

        // Verify the effects
        assertFalse(success);
    }

    /**
     * @dev Tests transferring tokens without any restrictions.
     */
    function testTransferWithoutRestrictions() public {
        // Set up
        address to = address(0x123);
        uint256 amount = 100;

        // Call the function
        (bool success, ) = address(restrictedToken).call(abi.encodeWithSignature("transfer(address,uint256)", to, amount));
        
        // Verify the effects
        assertTrue(success);
    }
}
