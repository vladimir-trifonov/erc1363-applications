// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "erc1363-payable-token/contracts/token/ERC1363/ERC1363.sol";
import "erc1363-payable-token/contracts/token/ERC1363/IERC1363Receiver.sol";
import "./IBondingToken.sol";
import "./utils/BondingCurve.sol";

/**
 * @title BondingToken
 * @dev A token contract that implements a bonding curve for buying and selling tokens using Ether.
 * The contract uses ERC1363 to accept and transfer tokens, and implements the IBondingToken interface for buying and selling tokens.
 * The contract also implements the IERC1363Receiver interface to receive tokens that are sent to the contract.
 */
contract BondingToken is ERC1363, IERC1363Receiver, IBondingToken {
    /**
     * @dev Throws if the caller is not the token contract.
     */
    modifier onlyAllowedToken() {
        require(
            msg.sender == address(this),
            "BondingToken: only allowed token"
        );
        _;
    }

    /**
     * @dev Initializes the contract with the given name and symbol.
     * @param _name The name of the token.
     * @param _symbol The symbol of the token.
     */
    constructor(
        string memory _name,
        string memory _symbol
    ) ERC20(_name, _symbol) {}

    /**
     * @dev Allows a user to buy tokens by sending Ether to the contract.
     * @param amount The amount of tokens to buy.
     */
    function buy(uint256 amount) public payable {
        require(msg.value > 0, "Insufficient funds");
        require(amount > 0, "Amount is zero");

        _buy(msg.sender, amount);
    }

    /**
     * @dev Internal function to buy tokens.
     * @param account The address of the account to receive the tokens.
     * @param amount The amount of tokens to buy.
     */
    function _buy(address account, uint256 amount) private {
        uint256 cost = calculatePriceForTokens(amount);
        _mint(account, amount);
        if (msg.value > cost) {
            payable(account).transfer(msg.value - cost);
        }

        emit Buy(account, amount);
    }

    /**
     * @dev Allows a user to sell tokens back to the contract in exchange for Ether.
     * @param amount The amount of tokens to sell.
     */
    function sell(uint256 amount) external {
        require(balanceOf(msg.sender) >= amount, "Insufficient funds");

        bool success = transfer(address(this), amount);
        if (!success) {
            revert("BondingToken: transfer failed");
        }
    }

    /**
     * @dev Internal function to sell tokens.
     * @param account The address of the account to receive the Ether.
     * @param amount The amount of tokens to sell.
     */
    function _sell(address account, uint256 amount) private {
        _burn(address(this), amount);
        uint256 payout = calculatePriceForTokens(amount);
        payable(account).transfer(payout);

        emit Sell(account, amount);
    }

    /**
     * @dev Overrides the ERC20 _afterTokenTransfer function to sell tokens when
     * they are transferred to the contract.
     * @param from The address of the account sending the tokens.
     * @param to The address of the account receiving the tokens.
     * @param amount The amount of tokens being transferred.
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        if (to == address(this)) {
            _sell(from, amount);
        }
    }

    /**
     * @dev Calculates the cost of buying a given amount of tokens.
     * @param amount The amount of tokens to calculate the cost for.
     * @return The cost of buying the given amount of tokens.
     */
    function calculatePriceForTokens(
        uint256 amount
    ) public view returns (uint256) {
        return BondingCurve.calculatePriceForTokens(amount, totalSupply());
    }

    /**
     * @dev Calculates the amount of tokens that can be bought with a given amount of Ether.
     * @param amount The amount of Ether to calculate the token amount for.
     * @return The amount of tokens that can be bought with the given amount of Ether.
     */
    function calculateTokensForPrice(
        uint256 amount
    ) public view returns (uint256) {
        return BondingCurve.calculateTokensForPrice(amount, totalSupply());
    }

    /**
     * @dev Called by ERC1363 to indicate that tokens have been transferred to the contract.
     */
    function onTransferReceived(
        address,
        address,
        uint256,
        bytes calldata
    ) external view override onlyAllowedToken returns (bytes4) {
        return BondingToken.onTransferReceived.selector;
    }

    /**
     * @dev Allows the contract to receive Ether by calling the buy function with the amount of tokens
     * that can be bought with the received Ether.
     */
    receive() external payable {
        buy(calculateTokensForPrice(msg.value));
    }
}
