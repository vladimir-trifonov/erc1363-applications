// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "forge-std/Test.sol";
import "../src/RestrictedToken.sol";

/**
 * @title TestRestrictedToken
 * @dev A contract for testing the RestrictedToken contract.
 */
contract TestRestrictedToken is Test {
    RestrictedToken token;
    uint256 initialSupply = 1000;

    event UpdateRestriction(address indexed account, bytes1 restriction);

    /**
     * @dev Initializes the test environment by deploying a new instance of the RestrictedToken contract.
     */
    function setUp() public {
        token = new RestrictedToken("Restricted Token", "RTK", initialSupply);
    }

    /**
     * @dev Tests the `supportsInterface` function of the RestrictedToken contract.
     */
    function testSupportsIRestrictedToken() public {
        // Set up
        bytes4 interfaceId = type(IRestrictedToken).interfaceId;

        // Verify the effects
        assertTrue(token.supportsInterface(interfaceId));
    }

    /**
     * @dev Tests the `supportsInterface` function of the RestrictedToken contract with invalid interface.
     */
    function testSupportsInvalidInterface() public {
        // Set up
        bytes4 interfaceId = bytes4(keccak256("invalidInterface()"));

        // Verify the effects
        assertFalse(token.supportsInterface(interfaceId));
    }

    /**
     * @dev Tests the `transferOwnership` function of the RestrictedToken contract.
     */
    function testTransferOwnership() public {
        // Set up
        address newOwner = vm.addr(1);

        // Call the function
        token.transferOwnership(newOwner);
        
        // Verify the effects
        assertEq(token.owner(), newOwner);
    }

    /**
     * @dev Tests the `updateRestriction` function of the RestrictedToken contract.
     */
    function testUpdateRestrictions() public {
        // Set up
        address account = vm.addr(1);
        bytes1 restriction = token.RESTRICTION_SEND();

        // Call the function
        token.updateRestriction(account, restriction);

        // Verify the effects
        assertEq(token.restrictions(account), restriction);
    }

    /**
     * @dev Tests the `updateRestriction` function of the RestrictedToken contract with the zero address.
     */
    function testUpdateRestrictionsForZeroAddress() public {
        // Set up
        address account = address(0);
        bytes1 restriction = token.RESTRICTION_SEND();

        // Call the function
        (bool success, ) = address(token).call(
            abi.encodeWithSignature(
                "updateRestriction(address,bytes1)",
                account,
                restriction
            )
        );

        // Verify the effects
        assertFalse(success);
        assertTrue(token.restrictions(account) != restriction);
    }

    /**
     * @dev Tests the `updateRestriction` function of the RestrictedToken contract with zero permission.
     */
    function testDeleteRestriction() public {
        // Set up
        address account = vm.addr(1);
        bytes1 restriction = token.RESTRICTION_SEND();
        token.updateRestriction(account, restriction);

        // Call the function
        token.updateRestriction(account, 0);

        // Verify the effects
        assertEq(token.restrictions(account), 0);
    }

    /**
     * @dev Tests the `UpdateRestriction` event of the RestrictedToken contract.
     */
    function testUpdateRestrictionEvent() public {
        // Set up
        address account = vm.addr(1);
        bytes1 restriction = token.RESTRICTION_SEND();
        vm.expectEmit(true, false, false, false, address(token));

        // We emit the event we expect to see.
        emit TestRestrictedToken.UpdateRestriction(account, restriction);

        // Call the function
        token.updateRestriction(account, restriction);
    }

    /**
     * @dev Tests the default restriction of the RestrictedToken contract.
     */
    function testDefaultRestrictions() public {
        // Set up
        address account = vm.addr(1);

        // Verify the effects
        assertEq(token.restrictions(account), 0);
    }

    /**
     * @dev Tests transferring tokens with a "send" restriction.
     */
    function testTransferWithRestrictionSend() public {
        // Set up
        address from = vm.addr(1);
        address to = vm.addr(2);
        uint256 amount = 100;
        token.transfer(from, amount);
        token.updateRestriction(from, token.RESTRICTION_SEND());

        // Call the function
        vm.prank(from);
        (bool success, ) = address(token).call(
            abi.encodeWithSignature("transfer(address,uint256)", to, amount)
        );

        // Verify the effects
        assertFalse(success);
    }

    /**
     * @dev Tests transferring tokens with a "receive" restriction.
     */
    function testTransferWithRestrictionReceive() public {
        // Set up
        address from = vm.addr(1);
        address to = vm.addr(1);
        uint256 amount = 100;
        token.transfer(from, amount);
        token.updateRestriction(to, token.RESTRICTION_RECEIVE());

        // Call the function
        vm.prank(from);
        (bool success, ) = address(token).call(
            abi.encodeWithSignature("transfer(address,uint256)", to, amount)
        );

        // Verify the effects
        assertFalse(success);
    }

    /**
     * @dev Tests transferring tokens without any restrictions.
     */
    function testTransferWithoutRestrictions() public {
        // Set up
        address to = vm.addr(1);
        uint256 amount = 100;

        // Call the function
        (bool success, ) = address(token).call(
            abi.encodeWithSignature("transfer(address,uint256)", to, amount)
        );

        // Verify the effects
        assertTrue(success);
    }
}
