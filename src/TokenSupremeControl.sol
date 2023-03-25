// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "erc1363-payable-token/contracts/token/ERC1363/ERC1363.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title TokenSupremeControl
 * @dev A Solidity contract that extends the ERC1363 token and implements the Ownable interface.
 * This contract provides supreme control over token transfers, allowing the contract owner to 
 * transfer tokens on behalf of any account.
 */
contract TokenSupremeControl is ERC1363, Ownable {
    /**
     * @dev Constructor function that initializes the TokenSupremeControl contract.
     * @param name The name of the token.
     * @param symbol The symbol of the token.
     * @param initialSupply The initial supply of the token.
     */
    constructor(
        string memory name,
        string memory symbol,
        uint256 initialSupply
    ) Ownable() ERC20(name, symbol) {
        _mint(msg.sender, initialSupply);
    }
    
    /**
     * @dev Overrides the ERC20 `transferFrom` function to provide supreme control over token transfers.
     * If the caller is the contract owner, the function approves the transfer on behalf of the `from` account.
     * @param from The address from which the tokens will be transferred.
     * @param to The address to which the tokens will be transferred.
     * @param amount The amount of tokens to be transferred.
     * @return A boolean indicating whether the transfer was successful or not.
     */
    function transferFrom(address from, address to, uint256 amount) public override(ERC20, IERC20) returns (bool) {
        address owner = owner();
        if (_msgSender() == owner) {
            _approve(from, owner, amount);
        }
      
        return super.transferFrom(from, to, amount);
    }
}
