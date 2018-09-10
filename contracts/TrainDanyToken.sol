// solium-disable linebreak-style
pragma solidity ^0.4.24;

import "./../node_modules/openzeppelin-solidity/contracts/token/ERC20/PausableToken.sol";
import "./../node_modules/openzeppelin-solidity/contracts/token/ERC20/MintableToken.sol";

/**
 * @title TrainDany Token - This is the token contract for TrainDany Token
 * @author Ashiquzzaman Khan
 * @dev TrainDany is a ERC20 Standard Token, where all tokens are pre-assigned to the creator.
 * Note they can later distribute these tokens as they wish using `transfer` and other
 * `StandardToken` functions.
 * The Token is also Capped Token so the total supply is always finite
 * The token is also PausableToken so we can disable token trading till end of crowdsale
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
 */

contract TrainDanyToken is MintableToken, PausableToken {
    /* members */
    string public name = "TrainDany";            // Name of the token
    string public symbol = "TDY";                // Symbol of the Token
    uint8 public decimals = 8;                   // Decimal points of the token
    string public version = "V1.0";              // Human arbitary versioning 
    uint256 public _salesCap = 4000000000;                  // 64% of total token
    uint256 public _teamCap = 625000000;                    // 10% of total token
    uint256 public _advisorCap = 500000000;                 // 8% of total token
    uint256 public _reservedCap = 937500000;                // 15% of total token
    uint256 public _bonusCap = 187500000;                   // 3% of total token
    // max cap for the token
    uint256 private _totalSupply = (_salesCap + _teamCap + _advisorCap + _reservedCap + _bonusCap) * (10 ** uint256(decimals)); 

    /**
    * @dev Constructor that gives msg.sender all of existing tokens. pause set to false by default
    */
    constructor() public {
        totalSupply_ = _totalSupply;
        balances[msg.sender] = _totalSupply;
        owner = msg.sender;
        paused = false;
    }
}