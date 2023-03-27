// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

/**
 * @title IBondingToken
 * @dev Interface for a bonding token contract that allows buying and selling of tokens at a calculated price.
 */
interface IBondingToken {
    /**
     * @dev Emitted when tokens are bought.
     * @param account The account that bought the tokens.
     * @param amount The amount of tokens bought.
     */
    event Buy(address indexed account, uint256 amount);
    
    /**
     * @dev Emitted when tokens are sold.
     * @param account The account that sold the tokens.
     * @param amount The amount of tokens sold.
     */
    event Sell(address indexed account, uint256 amount);

    /**
     * @dev Buy tokens with ETH at a calculated price.
     * @param amount The amount of tokens to buy.
     */
    function buy(uint256 amount) external payable;
    
    /**
     * @dev Sell tokens at a calculated price and receive ETH.
     * @param amount The amount of tokens to sell.
     */
    function sell(uint256 amount) external;
    
    /**
     * @dev Calculate the price for a given amount of tokens.
     * @param amount The amount of tokens to calculate the price for.
     * @return A The calculated price for the given amount of tokens.
     */
    function calculatePriceForTokens(uint256 amount) external view returns (uint256);
    
    /**
     * @dev Calculate the amount of tokens for a given price.
     * @param amount The price to calculate the amount of tokens for.
     * @return A The calculated amount of tokens for the given price.
     */
    function calculateTokensForPrice(uint256 amount) external view returns (uint256);
}
