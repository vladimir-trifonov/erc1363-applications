// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "forge-std/Test.sol";
import "erc1363-payable-token/contracts/token/ERC1363/IERC1363.sol";
import "../src/TokenSupremeControl.sol";

/**
 * @title TokenSupremeControlTest
 * @dev A contract to test the TokenSupremeControl contract functionality.
 */
contract TokenSupremeControlTest is Test {
    TokenSupremeControl token;
    uint256 initialSupply = 1000;

    /**
     * @dev Sets up the TokenSupremeControl contract instance before each test.
     */
    function setUp() public {
        token = new TokenSupremeControl(
            "Token Supreme Control",
            "TSC",
            initialSupply
        );
    }

    /**
     * @dev Tests if the TokenSupremeControl contract implements the IERC1363 interface.
     */
    function testERC1363() public {
        // Set up
        bool isERC1363 = token.supportsInterface(type(IERC1363).interfaceId);
        
        // Verify the effects
        assertTrue(isERC1363);
    }

    /**
     * @dev Tests if the TokenSupremeControl contract does not support an invalid interface.
     */
    function testSupportsInvalidInterface() public {
        // Set up
        bytes4 interfaceId = bytes4(keccak256("invalidInterface()"));

        // Verify the effects
        assertFalse(token.supportsInterface(interfaceId));
    }

    /**
     * @dev Tests the transferOwnership function of the TokenSupremeControl contract.
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
     * @dev Tests the transferFrom function of the TokenSupremeControl contract when called by the owner.
     */
    function testTransferFromWithOwner() public {
        // Set up
        address from = vm.addr(1);
        address to = vm.addr(2);
        uint256 amount = 100;
        token.transfer(from, amount);

        // Call the function
        token.transferFrom(from, to, amount);

        // Verify the effects
        assertEq(token.balanceOf(to), amount);
    }

    /**
     * @dev Tests the transferFrom function of the TokenSupremeControl contract when called by a non-owner.
     */
    function testTransferFromWithoutOwner() public {
        // Set up
        address from = vm.addr(1);
        address to = vm.addr(2);
        uint256 amount = 100;
        token.transfer(from, amount);
        vm.prank(from);
        token.approve(from, amount);

        // Call the function
        vm.prank(from);
        (bool success, ) = address(token).call(
            abi.encodeWithSignature(
                "transferFrom(address,address,uint256)",
                from,
                to,
                amount
            )
        );

        // Verify the effects
        assertTrue(success);
        assertEq(token.balanceOf(to), amount);
    }
}
