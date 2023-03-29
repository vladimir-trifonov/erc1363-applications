// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

/**
 * @title BondingCurve
 * @dev This library implements a bonding curve to calculate the price and number of tokens
 * for a given amount of Ether. The bonding curve function used in this library is:
 *
 *     P(n) = (((s + n + 1) ^ 3 - (s + 1) ^ 3) / 3) * MULTIPLIER
 *
 *     T(p) = cubeRoot((p / MULTIPLIER) * 3 + (s + 1) ^ 3) - s - 1
 *
 * where s is the current token supply, n is the number of tokens being purchased, p is the amount
 * of Ether being spent, and MULTIPLIER is 10^6. The bonding curve function is a cubic function.
 */
library BondingCurve {
    uint256 constant MULTIPLIER = 10 ** 6; // 1_000_000

    /**
     * @dev The `calculatePriceForTokens` function takes an amount of tokens and the current token supply
     * as input and returns the cost of purchasing that amount of tokens in Ether.
     *
     * priceForTokens = poolBalance(tokenSupply + amount) - poolBalance(tokenSupply)
     * poolBalance = ((tokenSupply + 1) ^ 3) / 3
     */
    function calculatePriceForTokens(
        uint256 amount,
        uint256 supply
    ) public pure returns (uint256) {
        return
            (((supply + amount + 1) ** 3 - (supply + 1) ** 3) / 3) * MULTIPLIER;
    }

    /**
     * @dev The `calculateTokensForPrice` function takes an amount of Ether and the current token supply
     * as input and returns the number of tokens that can be purchased with that amount of Ether.
     */
    function calculateTokensForPrice(
        uint256 amount,
        uint256 supply
    ) public pure returns (uint256) {
        uint256 root = cubeRoot((amount / MULTIPLIER) * 3 + (supply + 1) ** 3);
        require(root >= supply + 1, "Amount is too low");
        return root - supply - 1;
    }

    /**
     * @dev The `cubeRoot` function calculates the cube root of a non-negative integer using the nthRoot
     * function implemented using the binary search algorithm.
     */
    function cubeRoot(uint256 n) internal pure returns (uint256) {
        require(n >= 0, "Input must be non-negative");
        return nthRoot(n, 3);
    }

    /**
     * @dev  The nthRoot function calculates the integer n-th root of a non-negative integer x
     * using the binary search algorithm. The function begins by initializing the search
     * range to [0, x]. At each iteration of the loop, the function calculates the midpoint
     * mid of the search range and raises it to the n-th power. If mid^n is equal to x,
     * the function returns mid as the result. If mid^n is less than x, the search range is
     * updated to the right half of the previous range. If mid^n is greater than x, the search
     * range is updated to the left half of the previous range. The loop terminates when
     * the search range is reduced to a single integer value, which is then returned as the
     * largest integer y such that y^n <= x.
     *
     * Note: The binary search algorithm implemented in the nthRoot function has a time complexity
     * of O(log x), which makes it more efficient than Newton's method for large values of x.
     * However, the binary search algorithm can only calculate the integer n-th root of a
     * non-negative integer x. It cannot be used to calculate the real-valued n-th root of a
     * non-negative real number x, which is a limitation of the algorithm.
     */
    function nthRoot(uint256 x, uint256 n) internal pure returns (uint256) {
        require(x >= 0, "Input must be non-negative");
        require(n > 0, "Root must be positive");

        if (x == 0) {
            return 0;
        }

        uint256 left = 0;
        uint256 right = x;

        while (left < right) {
            uint256 mid = (left + right) / 2;
            uint256 midToNthPower = mid ** n;

            if (midToNthPower == x) {
                return mid;
            } else if (midToNthPower < x) {
                left = mid + 1;
            } else {
                right = mid;
            }
        }

        return left - 1;
    }
}
