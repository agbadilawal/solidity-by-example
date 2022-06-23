# ERC20 Token

## an erc20 token is a virtual coin that represents some sort of virtual property such as a share in a company, a voucher for some product or service.

Tokens are owned by ethereum addresses either Externally owned accounts or contract accounts ie. smart contracts, They are **fungible** so its units are interchangeable for each other since they all have similar value, Tokens can be transferred from one owner to another. It is controlled by a smart contract which acts as a ledger which keeps track of which addresses control which tokens.

::ERC20 tokens and ether are implemented at two different levels, ERC20 tokens are implemented outside the ethereum blockchain, it is implemented in solidity ie. its not part of the same codebase as ethereum client like _geth_ or _parity_::

its full specification can be found [here](https://eips.ethereum.org/EIPS/eip-20)



a more robust implementation of an ERC20 token contract can be found [here](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol)