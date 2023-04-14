// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import "erc1363-payable-token/contracts/token/ERC1363/ERC1363.sol";
import "erc1363-payable-token/contracts/token/ERC1363/IERC1363Receiver.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./IBondingToken.sol";
import "./utils/BondingCurve.sol";

/**
 * @title BondingToken
 * @dev A token contract that implements a bonding curve for buying and selling tokens using Ether.
 * The contract uses ERC1363 to accept and transfer tokens, and implements the IBondingToken interface for buying and selling tokens.
 * The contract also implements the IERC1363Receiver interface to receive tokens that are sent to the contract.
 */
contract BondingToken is ERC1363, IERC1363Receiver, IBondingToken, ReentrancyGuard {
    uint256 public constant MAX_BUY_AMOUNT_PER_TX = 1_000_000_000;
    uint256 public constant MAX_SUPPLY_THRESHOLD = 1_000_000_000_000;

    /**
     * @dev Throws if the caller is not the token contract.
     */
    modifier onlyAllowedToken() {
        require(msg.sender == address(this), "Only allowed token");
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
     * @dev Checks if a contract implements the IBondingToken interface.
     * @param interfaceId The interface ID being checked.
     * @return A boolean indicating if the contract implements the IBondingToken interface.
     */
    function supportsInterface(
        bytes4 interfaceId
    ) public view override(ERC1363) returns (bool) {
        return
            interfaceId == type(IBondingToken).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /**
     * @dev Allows a user to buy tokens by sending Ether to the contract.
     * @param amount The amount of tokens to buy.
     */
    function buy(uint256 amount) public payable nonReentrant {
        require(msg.value > 0, "Insufficient funds");
        require(amount > 0, "Amount is zero");
        require(amount <= MAX_BUY_AMOUNT_PER_TX, "Amount is too high");

        _buy(msg.sender, amount);
    }

    /**
     * @dev Internal function to buy tokens.
     * @param account The address of the account to receive the tokens.
     * @param amount The amount of tokens to buy.
     */
    function _buy(address account, uint256 amount) private {
        uint256 cost = calculatePriceForTokens(amount);
        require(msg.value >= cost, "Insufficient funds");
        _mint(account, amount);
        require(
            totalSupply() <= MAX_SUPPLY_THRESHOLD,
            "Max supply threshold reached"
        );
        if (msg.value > cost) {
            Address.sendValue(payable(account), msg.value - cost);
        }

        emit Buy(account, amount);
    }

    /**
     * @dev Allows a user to sell tokens back to the contract in exchange for Ether.
     * @param amount The amount of tokens to sell.
     */
    function sell(uint256 amount) external nonReentrant {
        require(balanceOf(msg.sender) >= amount, "Insufficient amount");

        bool success = transfer(address(this), amount);
        if (!success) {
            revert("Transfer failed");
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
        Address.sendValue(payable(account), payout);

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
        if (from != address(0) && to == address(this)) {
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
        return IERC1363Receiver.onTransferReceived.selector;
    }

    /**
     * @dev Allows the contract to receive Ether by calling the buy function with the amount of tokens
     * that can be bought with the received Ether.
     */
    fallback(
        bytes calldata _input
    ) external payable returns (bytes memory _output) {
        require(msg.value > 0, "Insufficient funds");
        uint256 amount = calculateTokensForPrice(msg.value);
        uint256 decoded = abi.decode(_input, (uint256));
        require(amount >= decoded, "Amount is not correct");
        buy(amount);
        return abi.encode(amount);
    }

    receive() external payable {
        revert("Not supported");
    }
}
