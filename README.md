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

The RestrictedToken contract implements the ERC1363 token standard, which is a standard for tokens that can be transferred and received by contracts as well as external accounts. The ERC1363 contract extends the ERC20 contract and adds additional functions

### Events

The RestrictedToken contract emits the following event:

- `UpdateRestrictions`: Emitted when the restrictions of an account are updated. Contains the following fields:
  - `account` (address): The address of the account whose restrictions were updated.
  - `restrictions` (bytes1): The new restrictions assigned to the account.
  
----

# TokenSupremeControl

TokenSupremeControl is a Solidity contract that extends the ERC1363 token and implements the Ownable interface.
This contract provides supreme control over token transfers, allowing the contract owner to transfer tokens on behalf of any account.

## Deployment

The TokenSupremeControl contract can be deployed using the Solidity compiler and a tool such as Remix.
The contract constructor requires the following arguments:

- `name` (string): The name of the token.
- `symbol` (string): The symbol of the token.
- `initialSupply` (uint256): The initial supply of the token.

## Usage

### Transfer Control

The TokenSupremeControl contract provides supreme control over token transfers, allowing the contract owner to transfer tokens on behalf of any account. The `transferFrom` function is overridden to provide this functionality.

### ERC1363

The TokenSupremeControl contract implements the ERC1363 token standard, which is a standard for tokens that can be transferred and received by contracts as well as external accounts. The ERC1363 contract extends the ERC20 contract and adds additional functions.

----

# BondingToken

BondingToken is a Solidity contract that implements a bonding curve for buying and selling tokens using Ether. The contract uses ERC1363 to accept and transfer tokens, and implements the IBondingToken interface for buying and selling tokens. The contract also implements the IERC1363Receiver interface to receive tokens that are sent to the contract.

## Deployment

The BondingToken contract can be deployed using the Solidity compiler and a tool such as Remix. The contract constructor requires the following arguments:

- `name` (string): The name of the token.
- `symbol` (string): The symbol of the token.


## Usage

Once deployed, users can buy tokens by sending Ether to the contract using the buy function. The amount of tokens to buy must be specified as a parameter to the function, and the amount of Ether sent must be greater than zero. The sell function can be used to sell tokens back to the contract in exchange for Ether. The amount of tokens to sell must be specified as a parameter to the function, and the account selling the tokens must have a sufficient balance.

The calculatePriceForTokens function can be used to calculate the cost of buying a given amount of tokens, while the calculateTokensForPrice function can be used to calculate the amount of tokens that can be bought with a given amount of Ether.

Finally, the contract can receive tokens by implementing the onTransferReceived function from the IERC1363Receiver interface. This function is called by the ERC1363 token contract when tokens are transferred to the BondingToken contract.


### Buying Tokens

The `buy` function allows a user to buy tokens by sending Ether to the contract. The function takes one argument:

- `amount` (uint256): The amount of tokens to buy.

### Selling Tokens

The `sell` function allows a user to sell tokens back to the contract in exchange for Ether. The function takes one argument:

- `amount` (uint256): The amount of tokens to sell.

### Price Calculation

The `calculatePriceForTokens` function calculates the cost of buying a given amount of tokens. The function takes one argument:

- `amount` (uint256): The amount of tokens to calculate the cost for.

The `calculateTokensForPrice` function calculates the amount of tokens that can be bought with a given amount of Ether. The function takes one argument:

- `amount` (uint256): The amount of Ether to calculate the token amount for.

### Receiving Tokens

The BondingToken contract implements the `onTransferReceived` function from the IERC1363Receiver interface to receive tokens that are sent to the contract.

### Events

The `Buy` event is emitted when tokens are bought:

```solidity
event Buy(address indexed account, uint256 amount);
```

The `Sell` event is emitted when tokens are sold:

```solidity
event Sell(address indexed account, uint256 amount);
```

## Bonding Curve

The BondingToken contract uses a bonding curve to determine the price of tokens. The bonding curve is defined in the `BondingCurve` library.

### Price Calculation

The `calculatePriceForTokens` function in the `BondingCurve` library calculates the cost of buying a given amount of tokens. The function takes two arguments:

- `amount` (uint256): The amount of tokens to calculate the cost for.
- `supply` (uint256): The total supply of tokens.

### Token Calculation

The `calculateTokensForPrice` function in the `BondingCurve` library calculates the amount of tokens that can be bought with a given amount of Ether. The function takes two arguments:

- `amount` (uint256): The amount of Ether to calculate the token amount for.
- `supply` (uint256): The total supply of tokens.

### Cube Root Calculation

The `nthRoot` function in the `BondingCurve` library calculates the cube root of a non-negative integer using the binary search algorithm.

## IBondingToken Interface

The `IBondingToken` interface defines the functions that the BondingToken contract implements for buying and selling tokens.

### Buying Tokens

The `buy` function allows a user to buy tokens by sending Ether to the contract. The function takes one argument:

- `amount` (uint256): The amount of tokens to buy.

### Selling Tokens

The `sell` function allows a user to sell tokens back to the contract in exchange for Ether. The function takes one argument:

- `amount` (uint256): The amount of tokens to sell.

### Price Calculation

The `calculatePriceForTokens` function calculates

### Restrictions

The BondingToken contract does not implement any restrictions on sending or receiving tokens. However, it implements the IBondingToken interface which defines two functions for calculating the cost of buying a given amount of tokens and the amount of tokens that can be bought with a given amount of Ether. The contract also implements the IERC1363Receiver interface to receive tokens that are sent to the contract.

# License

RestrictedToken, TokenSupremeControl and BondingToken are licensed under the MIT License. See `LICENSE` for more information.

