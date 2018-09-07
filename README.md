# TrainDany Token Contract and Customized Crowdsale Contract 
> Smart Contracts contained the ERC20 Token named TrainDany (TDY) and 3 staged Crowdsale.

[![Solidity Version][solidity-image]][solidity-url]
[![Test Status][token-test-image]][token-test-url]

TrainDany is a ERC20 Standard Token, where all tokens are pre-assigned to the creator.
 * Name is TrainDany, Symbol is TDY, Decimals are 8.
 * Note they can later distribute these tokens as they wish using `transfer` and other `StandardToken` functions.
 * The Token is also Capped Token so the total supply is always finite
 * The token is also PausableToken so we can disable token trading till end of crowdsale
 * Tokens offered through Presale would be 625 000 000 TDY Tokens (10% of total Sell token)
 * Tokens offered through Private Sale would be 625 000 000 TDY Tokens (10% of total Sell Token)
 * Tokens offered through Crowdsale would be 1 875 000 000 TDY Tokens (30% of total Sell Token)
 * Total Sellable Token would be 4 000 000 000 TDY Tokens (64%)
 * Bonus token would be 187 500 000 TDY Tokens (3%) 
 * For Team total 625 000 000 TDY would be reserved (10%)
 * For Advisor total 500 000 000 TDY would be Reserved (8%)
 * 937 500 000 TDY would be Reserved (15%)
 * There will be a max cap of 6 250 000 000 TDY tokens (100%)
 * Presale participants would be offered 30% extra tokens as bonus
 * Private participants would be offered 50% extra tokens as bonus
 * Crowdsale participants would be offered 20%, 10%, 5%, No bunus on respective weeks from start
 * Unsold TDY tokens can not be burnt or minted

## Installation & Setup

Download (Extras): 
- [NPM](https://www.npmjs.com/get-npm)
- [VS CODE](https://code.visualstudio.com/)
- [TRUFFLE](https://truffleframework.com/)
```bash
npm install -g truffle
```
- [GANACE-CLI](https://github.com/trufflesuite/ganache-cli)
```bash
npm install -g ganache-cli
```

OS X & Linux & Windows:

```bash
npm install --save-dev
```

## Usage example

To compile the project run:
```
truffle compile
```

To migrate the project run:
```
truffle migrate
```

To test the project run:
```
truffle test
```

To flat into a single contract run:
```
sh flatten.sh
```

## Release History

* V1.0
    * ADD: Basic ERC20 Token
    * ADD: 3 Stages Crowdsale Contracts
    * ADD: Distribution of Calculated Token 
## Meta

Ashiquzzaman Khan – [@dreadlordn](https://twitter.com/dreadlordn)

Distributed under the MIT license. See ``LICENSE`` for more information.

[https://github.com/PandorAstrum/SOL](https://github.com/PandorAstrum/SOL)

<!-- Markdown link & img dfn's -->
[solidity-image]: https://img.shields.io/badge/Solidity-0.4.24-yellowgreen.svg?style=flat-square
[solidity-url]: https://solidity.readthedocs.io/en/v0.4.24/

[token-test-image]: https://travis-ci.org/PandorAstrum/_vault.svg?branch=master
[token-test-url]: https://travis-ci.org/PandorAstrum/_vault