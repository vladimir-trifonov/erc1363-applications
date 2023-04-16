// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import "forge-std/Test.sol";
import "../../src/utils/BondingCurve.sol";

contract BondingCurveTest is Test {
    using BondingCurve for uint256;

    function testCalculatePriceForTokensBuySell() public {
        uint256 sum = 0;
        sum += BondingCurve.calculatePriceForTokens(1, 0);
        sum += BondingCurve.calculatePriceForTokens(1, 1);
        sum += BondingCurve.calculatePriceForTokens(1, 2);
        assertEq(sum, BondingCurve.calculatePriceForTokens(3, 0));
    }

    function testCalculatePriceForTokens() public {
        // Test with token supply of 0 and amount of 100 tokens
        uint256 amount = 100;
        uint256 supply = 0;
        uint256 expectedPrice = 0.000000343433333300 ether;
        uint256 actualPrice = BondingCurve.calculatePriceForTokens(
            amount,
            supply
        );
        assertEq(actualPrice, expectedPrice);

        // Test with token supply of 100 and amount of 50 tokens
        amount = 50;
        supply = 100;
        expectedPrice = 0.000000804216666650 ether;
        actualPrice = BondingCurve.calculatePriceForTokens(amount, supply);
        assertEq(actualPrice, expectedPrice);

        // Test with token supply of 1000 and amount of 200 tokens
        amount = 20_000;
        supply = 1_000;
        expectedPrice = 3.087106686666660000 ether;
        actualPrice = BondingCurve.calculatePriceForTokens(amount, supply);
        assertEq(actualPrice, expectedPrice);
    }

    function testCalculateTokensForPrice() public {
        // Test with token supply of 0 and price of 1 Ether
        uint256 amount = 1 ether; // 1 Ether
        uint256 supply = 0;
        uint256 expectedTokens = 14_421; // 14,421 tokens
        uint256 actualTokens = BondingCurve.calculateTokensForPrice(
            amount,
            supply
        );
        assertEq(actualTokens, expectedTokens);

        // Test with token supply of 100 and price of 0.5 Ether
        amount = 0.5 ether;
        supply = 100;
        expectedTokens = 11_346; // 11,346 tokens
        actualTokens = BondingCurve.calculateTokensForPrice(amount, supply);
        assertEq(actualTokens, expectedTokens);

        // Test with token supply of 1000 and price of 5 Ether
        amount = 5 ether;
        supply = 1_000;
        expectedTokens = 23_661; // 23,661 tokens
        actualTokens = BondingCurve.calculateTokensForPrice(amount, supply);
        assertEq(actualTokens, expectedTokens);

        // Test with token supply of 1000 and price of 50 Ether
        amount = 50 ether;
        supply = 1_000;
        expectedTokens = 52_132; // 52,132 tokens
        actualTokens = BondingCurve.calculateTokensForPrice(amount, supply);
        assertEq(actualTokens, expectedTokens);

        // Test with token supply of 1000 and price of 500 Ether
        amount = 500 ether;
        supply = 1_000;
        expectedTokens = 11_3470; // 11,3470 tokens
        actualTokens = BondingCurve.calculateTokensForPrice(amount, supply);
        assertEq(actualTokens, expectedTokens);
    }

    function testNthRoot() public {
        // Test with input of 0 and root of 3
        uint256 x = 0;
        uint256 n = 3;
        uint256 expectedRoot = 0;
        uint256 actualRoot = BondingCurve.nthRoot(x, n);
        assertEq(actualRoot, expectedRoot);

        // Test with input of 1_000 and root of 3
        x = 1_000;
        n = 3;
        expectedRoot = 10;
        actualRoot = BondingCurve.nthRoot(x, n);
        assertEq(actualRoot, expectedRoot);

        // Test with input of 1_000_000 and root of 3
        x = 1_000_000;
        n = 3;
        expectedRoot = 100;
        actualRoot = BondingCurve.nthRoot(x, n);
        assertEq(actualRoot, expectedRoot);

        // Test with input of 1_000_000_000_000 and root of 5
        x = 1_000_000_000_000;
        n = 5;
        expectedRoot = 251;
        actualRoot = BondingCurve.nthRoot(x, n);
        assertEq(actualRoot, expectedRoot);
    }

    function testCubeRoot() public {
        // Test with input of 0
        uint256 n = 0;
        uint256 expectedRoot = 0;
        uint256 actualRoot = BondingCurve.cubeRoot(n);
        assertEq(actualRoot, expectedRoot);

        // Test with input of 1_000
        n = 1_000;
        expectedRoot = 10;
        actualRoot = BondingCurve.cubeRoot(n);
        assertEq(actualRoot, expectedRoot);

        // Test with input of 1_000_000
        n = 1_000_000;
        expectedRoot = 100;
        actualRoot = BondingCurve.cubeRoot(n);
        assertEq(actualRoot, expectedRoot);

        // Test with input of 1_000_000_000
        n = 1_000_000_000;
        expectedRoot = 1000;
        actualRoot = BondingCurve.cubeRoot(n);
        assertEq(actualRoot, expectedRoot);
    }
}
