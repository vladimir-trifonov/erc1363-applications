// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "forge-std/Test.sol";
import "../src/BondingToken.sol";
import "../src/utils/BondingCurve.sol";

/**
 * @title BondingTokenTest
 * @dev A contract to test the BondingToken contract functionality.
 */
contract BondingTokenTest is Test {
    BondingToken token;

    /**
     * @dev Set up the BondingToken contract for each test case.
     */
    function setUp() public {
        token = new BondingToken(
            "Bonding Control",
            "TBN"
        );
    }
    
    /**
     * @dev Test the buy function of the BondingToken contract.
     */
    function testBuy() public {
        // Set up
        address buyer = vm.addr(1);
        uint256 amount = 1;
        vm.deal(buyer, 1 ether);
        uint256 balance = address(buyer).balance;

        // Call the function
        vm.prank(buyer);
        token.buy{value: 3_000_000}(amount);

        // Verify the effects
        assertEq(token.balanceOf(buyer), amount);
        assertEq(token.totalSupply(), amount);
        assertEq(address(buyer).balance, balance - BondingCurve.calculatePriceForTokens(1, 0));
    }
    
    /**
     * @dev Test the sell function of the BondingToken contract.
     */
    function testSell() public {
        // Set up
        address buyer = vm.addr(1);
        uint256 amount = 1 ether;
        vm.deal(buyer, amount);
        uint256 balance = address(buyer).balance;
        vm.prank(buyer);
        (bool success, ) = address(token).call{value: amount}("");
        uint256 tokens = token.balanceOf(buyer);

        // Call the function
        vm.prank(buyer);
        token.sell(tokens);

        // Verify the effects
        assertTrue(success);
        assertEq(token.balanceOf(buyer), 0);
        assertEq(token.totalSupply(), 0);
        assertEq(address(buyer).balance, balance);
    }
}
