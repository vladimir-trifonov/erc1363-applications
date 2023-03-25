// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "erc1363-payable-token/contracts/token/ERC1363/ERC1363.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./IRestrictedToken.sol";
import "./utils/Bitwise.sol";

/**
 * @title RestrictedToken
 * @dev A Solidity contract that extends the ERC1363 token and implements the IRestrictedToken interface.
 * This contract defines restrictions on sending and receiving tokens for individual accounts.
 */
contract RestrictedToken is ERC1363, IRestrictedToken, Ownable {

    bytes1 public immutable RESTRICTION_SEND = 0x01; // 0000 0001
    bytes1 public immutable RESTRICTION_RECEIVE = 0x02; // 0000 0010

    mapping(address => bytes1) public restrictions;

    /**
     * @dev Constructor function that initializes the RestrictedToken contract.
     * @param name The name of the token.
     * @param symbol The symbol of the token.
     * @param initialSupply The initial supply of the token.
     */
    constructor(
        string memory name,
        string memory symbol,
        uint256 initialSupply
    ) Ownable() ERC20(name, symbol) {
        _mint(owner(), initialSupply);
    }

    /**
     * @dev Checks if a contract implements the IRestrictedToken interface.
     * @param interfaceId The interface ID being checked.
     * @return A boolean indicating if the contract implements the IRestrictedToken interface.
     */
    function supportsInterface(
        bytes4 interfaceId
    ) public view override(ERC1363) returns (bool) {
        return
            interfaceId == type(IRestrictedToken).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /**
     * @dev Updates the restriction for a given account. Only the contract owner can call this function.
     * @param account The address of the account which restriction is being updated.
     * @param restriction The new restriction to assign to the account.
     */
    function updateRestriction(
        address account,
        bytes1 restriction
    ) external onlyOwner {
        require(
            account != address(0),
            "RestrictedToken: account is the zero address"
        );

        _updateRestriction(account, restriction);
    }

    /**
     * @dev Internal function to update the restriction for a given account.
     * @param account The address of the account which restriction is being updated.
     * @param restriction The new restriction to assign to the account.
     */
    function _updateRestriction(address account, bytes1 restriction) private {
        if (restriction == 0) {
            delete restrictions[account];
        } else {
            restrictions[account] = restriction;
        }

        emit UpdateRestriction(account, restriction);
    }

    /**
     * @dev Checks the restriction before a token transfer occurs.
     * @param from The address of the account sending the tokens.
     * @param to The address of the account receiving the tokens.
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256
    ) internal view override {
        require(
            from == address(0) ||
                !Bitwise.check(restrictions[from], RESTRICTION_SEND),
            "RestrictedToken: address from has restriction to send"
        );
        require(
            to == address(0) ||
                !Bitwise.check(restrictions[to], RESTRICTION_RECEIVE),
            "RestrictedToken: address to has restriction to receive"
        );
    }
}
