# RestrictedToken

RestrictedToken is a Solidity contract that extends the ERC1363 token and implements the IRestrictedToken interface. This contract defines restrictions on sending and receiving tokens for individual accounts. It is useful for situations where token transfers need to be restricted based on certain criteria.

## Deployment

The RestrictedToken contract can be deployed using the Solidity compiler and a tool such as Remix. The contract constructor requires the following arguments:

- `name` (string): The name of the token.
- `symbol` (string): The symbol of the token.
- `initialSupply` (uint256): The initial supply of the token.

## Usage

### Restrictions

The RestrictedToken contract allows for restrictions on sending and receiving tokens for individual accounts. Restrictions are represented by a single byte of data, where the following bits represent the corresponding restrictions:

- `0x01`: Send restriction.
- `0x02`: Receive restriction.

The `RESTRICTION_SEND` and `RESTRICTION_RECEIVE` constants are provided to indicate the respective restrictions.

The `updateRestrictions` function can be called by the contract owner to update the restrictions of a specific account. The function takes two arguments:

- `account` (address): The address of the account whose restrictions are being updated.
- `restrictions` (bytes1): The new restrictions to assign to the account.

The `restrictions` mapping can be used to retrieve the restrictions of a specific account.

### ERC1363

The RestrictedToken contract implements the ERC1363 token standard, which is a standard for tokens that can be transferred and received by contracts as well as external accounts. The ERC1363 contract extends the ERC20 contract and adds two additional functions:

- `transferAndCall`: Transfers tokens to a recipient and calls a function on the recipient contract.
- `transferFromAndCall`: Transfers tokens from a sender to a recipient and calls a function on the recipient contract.

### Events

The RestrictedToken contract emits the following event:

- `UpdateRestrictions`: Emitted when the restrictions of an account are updated. Contains the following fields:
  - `account` (address): The address of the account whose restrictions were updated.
  - `restrictions` (bytes1): The new restrictions assigned to the account.

## License

RestrictedToken is licensed under the MIT License. See `LICENSE` for more information.
