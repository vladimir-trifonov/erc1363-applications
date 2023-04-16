// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import "forge-std/Test.sol";
import "../src/BondingToken.sol";
import "../src/utils/BondingCurve.sol";

/**
 * @title BondingTokenTest
 * @dev A contract to test the BondingToken contract functionality.
 */
contract BondingTokenTest is Test {
    BondingToken token;
    uint256 private MAX_BUY_AMOUNT_PER_TX;

    event Buy(address indexed account, uint256 amount);
    event Sell(address indexed account, uint256 amount);

    /**
     * @dev Set up the BondingToken contract for each test case.
     */
    function setUp() public {
        token = new BondingToken("Bonding Control", "TBN");
        MAX_BUY_AMOUNT_PER_TX = token.MAX_BUY_AMOUNT_PER_TX();
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
     * @dev Test the buy function of the BondingToken contract with fuzzing.
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
     * @dev Test the buy function of the BondingToken contract by bying multiple tokens.
     */
    function testMultyBuy() public {
        // Set up
        address buyer = vm.addr(1);
        // Not using even numbers to be able to test the rounding
        uint256 amount = 83452;
        uint256 totalPrice = BondingCurve.calculatePriceForTokens(amount, 0);
        uint256 sumPrice = 0;
        vm.startBroadcast(buyer);

        for (uint256 i = 0; i < amount; i++) {
            uint256 price = token.calculatePriceForTokens(1);
            // Call the function
            vm.deal(buyer, price);
            token.buy{value: price}(1);
            sumPrice += price;
        }

        vm.stopBroadcast();
        // Verify the effects
        assertEq(token.balanceOf(buyer), amount);
        assertEq(token.totalSupply(), amount);
        assertEq(sumPrice, totalPrice);
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
        (bool success, ) = address(token).call{value: value}(
            abi.encode(tokens)
        );

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
        (bool success, ) = address(token).call{value: value}(
            abi.encode(tokens)
        );

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
     * @dev Test the sell function of the BondingToken contract by selling multiple tokens.
     */
    function testMultySell() public {
        // Set up
        address buyer = vm.addr(1);
        // Not using even numbers to be able to test the rounding
        uint256 amount = 92354;
        uint256 sumPayout = 0;
        vm.startBroadcast(buyer);

        uint256 totalPrice = token.calculatePriceForTokens(amount);
        // Call the function
        vm.deal(buyer, totalPrice);
        token.buy{value: totalPrice}(amount);

        uint256 balance = address(buyer).balance;
        assertEq(balance, 0);

        while (amount > 0) {
            // Not using even numbers to be able to test the rounding
            uint256 tokens = amount > 33 ? 33 : amount;
            uint256 prev = address(buyer).balance;
            token.sell(tokens);
            uint256 price = token.calculatePriceForTokens(tokens);
            assertEq(address(buyer).balance, prev + price);
            sumPayout += price;
            amount -= tokens;
        }

        vm.stopBroadcast();
        // Verify the effects
        assertEq(token.balanceOf(buyer), 0);
        assertEq(token.totalSupply(), 0);
        assertEq(sumPayout, totalPrice);
        assertEq(address(buyer).balance, sumPayout);
        assertEq(address(token).balance, 0);
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
        (bool success, ) = address(token).call{value: value}(
            abi.encode(tokens)
        );

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
     * @dev Test the buy and sell function of the BondingToken contract.
     */
    function testBuySell() public {
        // Set up
        address buyer = vm.addr(1);
        vm.startBroadcast(buyer);
        uint256 buyPriceSum = 0;

        // Call the function
        uint256 price1 = token.calculatePriceForTokens(1);
        buyPriceSum += price1;
        vm.deal(buyer, price1);
        token.buy{value: price1}(1);
        uint256 price2 = token.calculatePriceForTokens(1);
        buyPriceSum += price2;
        vm.deal(buyer, price2);
        token.buy{value: price2}(1);
        uint256 price3 = token.calculatePriceForTokens(1);
        buyPriceSum += price3;
        vm.deal(buyer, price3);
        token.buy{value: price3}(1);
        token.sell(3);
        vm.stopBroadcast();

        // Verify the effects
        assertEq(token.balanceOf(buyer), 0);
        assertEq(token.totalSupply(), 0);
        assertEq(address(buyer).balance, buyPriceSum);
        assertEq(address(token).balance, 0);
        assertEq(buyPriceSum, BondingCurve.calculatePriceForTokens(3, 0));
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
        (bool ret, ) = address(token).call{value: value}(abi.encode(tokens));

        // Call the function
        vm.prank(buyer);
        bool success = token.transferAndCall(address(token), tokens);

        // Verify the effects
        assertTrue(ret);
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
