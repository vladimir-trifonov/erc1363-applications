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
    uint256 constant MAX_BUY_AMOUNT_PER_TX = 1_000_000_000;

    event Buy(address indexed account, uint256 amount);
    event Sell(address indexed account, uint256 amount);

    /**
     * @dev Set up the BondingToken contract for each test case.
     */
    function setUp() public {
        token = new BondingToken("Bonding Control", "TBN");
    }

    /**
     * @dev Tests the `supportsInterface` function of the BondingToken contract.
     */
    function testSupportsIBondingToken() public {
        // Set up
        bytes4 interfaceId = type(IBondingToken).interfaceId;

        // Verify the effects
        assertTrue(token.supportsInterface(interfaceId));
    }

    /**
     * @dev Tests the `supportsInterface` function of the BondingToken contract with invalid interface.
     */
    function testSupportsInvalidInterface() public {
        // Set up
        bytes4 interfaceId = bytes4(keccak256("invalidInterface()"));

        // Verify the effects
        assertFalse(token.supportsInterface(interfaceId));
    }

    /**
     * @dev Test the buy function of the BondingToken contract.
     */
    function testFuzz_Buy(uint256 amount) public {
        // Set up
        vm.assume(amount > 0 && amount <= MAX_BUY_AMOUNT_PER_TX);
        address buyer = vm.addr(1);
        uint256 price = BondingCurve.calculatePriceForTokens(amount, 0);
        vm.deal(buyer, price);
        uint256 balance = address(buyer).balance;

        // Call the function
        vm.prank(buyer);
        token.buy{value: price}(amount);

        // Verify the effects
        assertEq(token.balanceOf(buyer), amount);
        assertEq(token.totalSupply(), amount);
        assertEq(address(buyer).balance, balance - price);
    }

    /**
     * @dev Test the buy event of the BondingToken contract.
     */
    function testEventBuy() public {
        // Set up
        address buyer = vm.addr(1);
        uint256 amount = 1;
        uint256 price = BondingCurve.calculatePriceForTokens(amount, 0);
        vm.deal(buyer, price);

        // Expect the event
        vm.expectEmit(true, false, false, true);

        // We emit the event we expect to see.
        emit BondingTokenTest.Buy(buyer, amount);

        // Call the function
        vm.prank(buyer);
        token.buy{value: price}(amount);
    }

    /**
     * @dev Test the buy through the payable callback function of the BondingToken contract.
     */
    function testRevert_BuyPayableCallback() public {
        // Set up
        address buyer = vm.addr(1);
        uint256 value = 1 ether;
        uint256 tokens = BondingCurve.calculateTokensForPrice(value, 0);
        uint256 price = BondingCurve.calculatePriceForTokens(tokens, 0);
        hoax(buyer);
        uint256 balance = address(buyer).balance;

        // Call the function
        (bool success, ) = address(token).call{value: value}(abi.encode(tokens));

        // Verify the effects
        assertTrue(success);
        assertEq(token.balanceOf(buyer), tokens);
        assertEq(token.totalSupply(), tokens);
        assertEq(address(buyer).balance, balance - price);
    }

    /**
     * @dev Test the sell function of the BondingToken contract.
     */
    function testSell() public {
        // Set up
        address buyer = vm.addr(1);
        uint256 value = 1 ether;
        uint256 tokens = BondingCurve.calculateTokensForPrice(value, 0);
        hoax(buyer);
        uint256 balance = address(buyer).balance;
        (bool success, ) = address(token).call{value: value}(abi.encode(tokens));

        // Call the function
        vm.prank(buyer);
        token.sell(tokens);

        // Verify the effects
        assertTrue(success);
        assertEq(token.balanceOf(buyer), 0);
        assertEq(token.totalSupply(), 0);
        assertEq(address(buyer).balance, balance);
    }

    /**
     * @dev Test the sell event of the BondingToken contract.
     */
    function testEventSell() public {
        // Set up
        address buyer = vm.addr(1);
        uint256 value = 1 ether;
        uint256 tokens = BondingCurve.calculateTokensForPrice(value, 0);
        hoax(buyer);
        (bool success, ) = address(token).call{value: value}(abi.encode(tokens));

        // Expect the event
        vm.expectEmit(true, false, false, true);

        // We emit the event we expect to see.
        emit BondingTokenTest.Sell(buyer, tokens);

        // Call the function
        vm.prank(buyer);
        token.sell(tokens);

        // Verify the effects
        assertTrue(success);
    }

    /**
     * @dev Test the sell through transfer and call function of the BondingToken contract.
     */
    function testSellTransferAndCall() public {
        // Set up
        address buyer = vm.addr(1);
        uint256 value = 1 ether;
        uint256 tokens = BondingCurve.calculateTokensForPrice(value, 0);
        hoax(buyer);
        uint256 balance = address(buyer).balance;
        (bool success, ) = address(token).call{value: value}(abi.encode(tokens));

        // Call the function
        vm.prank(buyer);
        token.transferAndCall(address(token), tokens);

        // Verify the effects
        assertTrue(success);
        assertEq(token.balanceOf(buyer), 0);
        assertEq(token.totalSupply(), 0);
        assertEq(address(buyer).balance, balance);
    }

    /**
     * @dev Test the buy function of the BondingToken contract with zero amount.
     */
    function testRevert_BuyZeroAmount() public {
        // Set up
        address buyer = vm.addr(1);
        uint256 amount = 0;
        uint256 price = BondingCurve.calculatePriceForTokens(1, 0);

        // Expect revert
        vm.expectRevert("Amount is zero");

        // Call the function
        hoax(buyer);
        token.buy{value: price}(amount);
    }

    /**
     * @dev Test the buy function of the BondingToken contract with insufficient funds.
     */
    function testRevert_BuyInsufficientFunds() public {
        // Set up
        address buyer = vm.addr(1);
        uint256 amount = 1;
        hoax(buyer);

        // Expect revert
        vm.expectRevert("Insufficient funds");

        // Call the function
        token.buy(amount);
    }

    /**
     * @dev Test the buy function of the BondingToken contract with too hight amount.
     */
    function testRevert_BuyOverMaxBuyAmount() public {
        // Set up
        address buyer = vm.addr(1);
        uint256 amount = MAX_BUY_AMOUNT_PER_TX + 1;
        hoax(buyer);

        // Expect revert
        vm.expectRevert("Amount is too high");

        // Call the function
        token.buy{value: 100}(amount);
    }

    /**
     * @dev Test the buy function of the BondingToken contract with more ether than the actual price of the tokens.
     */
    function testBuyOverPriced() public {
        // Set up
        address buyer = vm.addr(1);
        uint256 amount = 1;
        uint256 price = BondingCurve.calculatePriceForTokens(amount, 0);
        uint256 overprice = price + 10_000_000;
        hoax(buyer);
        uint256 balance = address(buyer).balance;

        // Call the function
        token.buy{value: overprice}(amount);

        // Verify the effects
        assertEq(token.balanceOf(buyer), amount);
        assertEq(token.totalSupply(), amount);
        assertEq(address(buyer).balance, balance - price);
    }

    /**
     * @dev Test the sell function of the BondingToken contract with insufficient funds.
     */
    function testRevert_SellInsufficientAmount() public {
        // Set up
        address buyer = vm.addr(1);

        // Expect revert
        vm.expectRevert("Insufficient amount");

        // Call the function
        vm.prank(buyer);
        token.sell(1);
    }
}
