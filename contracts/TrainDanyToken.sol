// solium-disable linebreak-style
pragma solidity ^0.4.24;

import "./../node_modules/openzeppelin-solidity/contracts/token/ERC20/StandardToken.sol";
import "./../node_modules/openzeppelin-solidity/contracts/token/ERC20/PausableToken.sol";
import "./../node_modules/openzeppelin-solidity/contracts/token/ERC20/DetailedERC20.sol";
import "./../node_modules/openzeppelin-solidity/contracts/ownership/Ownable.sol";

/**
 * @title TrainDany Token - This is the token contract for TrainDany Token
 * @author Ashiquzzaman Khan
 * @dev TrainDany is a ERC20 Standard Token, where all tokens are pre-assigned to the creator.
 * Note they can later distribute these tokens as they wish using `transfer` and other
 * `StandardToken` functions.
 * The Token is also Capped Token so the total supply is always finite
 * The token is also PausableToken so we can disable token trading till end of crowdsale
 * There will be a max cap of 6 250 000 000 TDY tokens 
 * Tokens offered through Presale would be 625 000 000 TDY Tokens (10%)
 * Tokens offered through Private Sale would be 625 000 000 TDY Tokens (10%)
 * Tokens offered through Crowdsale would be 1 875 000 000 TDY Tokens (30%)
 * Total Sellable Token would be 3 125 000 000 TDY Tokens (50%)
 * 40% would be at the end of crowdsale and transferred to the TDY Token Reserve
 * Presale participants would be offered 30% extra tokens as bonus
 * Private participants would be offered 50% extra tokens as bonus
 * Crowdsale participants would be offered 20%, 10%, 5%, No bunus on respective weeks from start
 * Unsold TDY tokens can not be burnt or minted
 */

contract TrainDanyToken is DetailedERC20, StandardToken, PausableToken {
    /* members */
    string private constant _name = "TrainDany";            // Name of the token
    string private constant _symbol = "TDY";                // Symbol of the Token
    uint8 private constant _decimals = 8;                   // Decimal points of the token
    string private constant _version = "V1.0";              // Human arbitary versioning 
    uint256 private _salesCap = 4000000000;                 // 64% of total token
    uint256 private _teamCap = 625000000;                   // 10% of total token
    uint256 private _advisorCap = 500000000;                // 8% of total token
    uint256 private _reservedCap = 937500000;               // 15% of total token
    uint256 private _bonusCap = 187500000;                  // 3% of total token
    // max cap for the token
    uint256 private constant _totalSupply = (_salesCap + _teamCap + _advisorCap + _reservedCap + _bonusCap) * (10 ** uint256(decimals)); 

    /**
    * @dev Constructor that gives msg.sender all of existing tokens.
    */
    constructor() 
        DetailedERC20(_name, _symbol, _decimals)
        public {
        totalSupply_ = _totalSupply;
        balances[msg.sender] = _totalSupply;
        owner = msg.sender;
        paused = false;
    }

    function version() public view returns(string){
        return _version;
    }

    function teamCap() onlyOwner public view returns(uint256) {
        return _teamCap;
    }

    function advisorCap() onlyOwner public view returns(uint256) {
        return _advisorCap;
    }

    function salesCap() onlyOwner public view returns(uint256) {
        return _salesCap;
    }

    function reservedCap() onlyOwner public view returns(uint256) {
        return _reservedCap;
    }

    function bonusCap() onlyOwner public view returns(uint256) {
        return _bonusCap;
    }
}

/**
 * @title TDY Token
 * @dev ERC20 Token Implementation on TDY Token, where all tokens are pre-assigned to the creator.
 * Note they can later distribute these tokens as they wish using `transfer` and other
 * `StandardToken` functions.

 Criteria ------------------------------------------------

    Bonus&Bounty : yes 
    eth adress 0x3B6a332f204CB12a45afb4e03ae5E600f71E6BB9 (Done) t
    Duration & Deadline : 25oct-25nov (implementation stage) 
    Funding Goal in Wei : 15625000000000000000000 (Done) c
    Price in Wei : 25000000000000 (Done) c
    Minimum invstement 0.1ETH (or equivalent in BTC ETH LTC BCH) (Done) c
    Max invest : no-limit (Done) c
    1 TDY = 0.000025ETH (Done) c
    KYC (know your customers) : Yes (Implementation stage)
    Beneficiary Address (If success send to this address) : 0x3B6a332f204CB12a45afb4e03ae5E600f71E6BB9 (same as eth adress ?)
    64% distributed to comunity 
    3% bounty 
    15% reserve 
    10% team
    8% Advisor
    
    --Token sale stage in 3 stages

    --Stage 1 private sell
        token available : 625 000 000 TDY
        Bonus 50%
        minimum invst 250 ETH
        25 sept to 05 oct

    --Stage 2 pre-sell
        token available : 625 000 000 TDY
        Bonus 30%
        Mini invest : 0.1 ETH
        05 oct to 25 oct

    --Stage 3 Public sell
        token available : 1 875 000 000 TDY
        Bonus : from 25 oct 25 Nov
        1st week 20%
        2nd week : 10%
        3rd week : 5%
        4th week : No Bonus

        Mini invest : 0.1 ETH
        Duration 30 days


TEAM : 625 000 000 TDY in total for the team

- 31
2 500 000 TDY blocked for 1 year
- 312 500 000 TDY blocked for 2 year

ADVISORS : 500 000 000 TDY in total for advisors
Blocked for 6 month

only 3 125 000 000 are in sells, the rest is given as bonus to reach 64% of the 4 000 000 000 supply
*/