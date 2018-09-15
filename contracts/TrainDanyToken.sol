// solium-disable linebreak-style
pragma solidity ^0.4.24;

import "./../node_modules/openzeppelin-solidity/contracts/token/ERC20/PausableToken.sol";
import "./../node_modules/openzeppelin-solidity/contracts/access/rbac/RBAC.sol";

/**
 * @title TrainDany Token - This is the token contract for TrainDany Token
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

contract TrainDanyToken is PausableToken, RBAC {
    //TODO: lock account for certain time

    string public name = "TrainDany";                           // Name of the token
    string public symbol = "TDY";                               // Symbol of the Token
    uint8 public decimals = 8;                                  // Decimal points of the token
    string public version = "V1.0";                             // Human arbitary versioning 
    uint256 private salesCap = 4000000000;                      // 64% of total token without decimals
    uint256 private teamCap = 625000000;                        // 10% of total token without decimals
    uint256 private advisorCap = 500000000;                     // 8% of total token without decimals
    uint256 private reservedCap = 937500000;                    // 15% of total token without decimals
    uint256 private bonusCap = 187500000;                       // 3% of total token without decimals
    uint256 private _totalSupply = (salesCap + teamCap + advisorCap + reservedCap + bonusCap) * (10 ** uint256(decimals)); // max cap for the token
    uint256 private totalTransferToAdvisor;                     // tracker for how many tokens gone to advisor
    uint256 private totalTransferToTeam;                        // tracker for how many tokens gone to team
    uint256 private totalTransferToReserved;                    // tracker for how many tokens gone to reserved
    uint256 private totalTransferToSales;                       // tracker for how many tokens gone to sales
    uint256 private totalTransferToBonus;                       // tracker for how many tokens gone to bonus

    mapping (address => bool) public frozenAccount;             // mapping for frozen account                
    /**
    * @dev Events for Frozen Funds
    * @param target the address whose account will be frozen
    * @param releaseTime the time until the account will be frozen
    */
    event FrozenFunds(address indexed target, uint256 releaseTime);

    /**
    * @dev Constructor that gives msg.sender all of existing tokens. pause set to false by default
    */
    constructor() public {
        totalSupply_ = _totalSupply;
        balances[msg.sender] = _totalSupply;
        owner = msg.sender;
        paused = false;
    }
    /**
    * @dev freeze functions Prevent | Allow` `target` from sending & receiving tokens
    * @param _target Address to be frozen
    * @param _freeze either to freeze it or not (true | False)
    * @param _releaseTime time until the accounts will be prevented from sending or recieving any token
    */
    function freezeAccount(address _target, bool _freeze, uint256 _releaseTime) public onlyOwner {
        frozenAccount[_target] = _freeze;
        emit FrozenFunds(_target, _releaseTime);
    }
    
    /**
    * @dev function for adding roles to an address
    * @param _target an array of address for the role. e.g: ["0x0", "0x0"]
    * @param _roles string text of the role. All in small letters followd by A capital letter. e.g: "Advisors"
    */
    function addRoles(address[] _target, string _roles) public onlyOwner {
        for (uint i = 0; i < _target.length; i++) {
            addRole(_target[i], _roles);
        }
    }
        /**
    * @dev function for removing roles to an address
    * @param _target an array of address for the role. e.g: ["0x0", "0x0"]
    * @param _roles string text of the role. All in small letters followd by A capital letter. e.g: "Advisors"
    */
    function removeRoles(address[] _target, string _roles) public onlyOwner {
        for (uint i = 0; i < _target.length; i++) {
            removeRole(_target[i], _roles);
        }
    }

    /**
    * @dev function for getting back the amount of remaining token for given roles and shares
    * @param _roles string to specify the roles . e.g: 'advisor', 'team', 'reserved', 'sales'
    * @return the amount of remaining token
    */
    function remainingTokensFor(string _roles) public onlyOwner view returns(uint256){
        if (keccak256(_roles) == keccak256("Advisors")){
            return (advisorCap - totalTransferToAdvisor);
        } else if (keccak256(_roles) == keccak256("Team")) {
            return (teamCap - totalTransferToTeam);
        } else if (keccak256(_roles) == keccak256("Reserved")) {
            return (reservedCap - totalTransferToReserved);
        } else if (keccak256(_roles) == keccak256("Sales")) {
            return (salesCap - totalTransferToSales);
        } else if (keccak256(_roles) == keccak256("Bonus")) {
            return (bonusCap - totalTransferToBonus);
        }
    }

    /**
    * @dev overriding transfer function for extra logic
    */
    function transfer(address _to, uint256 _value) public returns(bool) {
        // check if the account is freezed
        require(!frozenAccount[msg.sender], "The sender accoutn is Frozen");
        require(!frozenAccount[_to], "The Reciever Account is Frozen");
        // check if the account is freezed
        checker(_to, _value);

        super.transfer(_to, _value);
    }
    /**
    * @dev oberriding transferFrom function for extra logic
    */
    function transferFrom(address _from, address _to, uint256 _value) public returns(bool) {
        // check if the account is freezed
        require(!frozenAccount[_from], "The Sender Account is Frozen");
        require(!frozenAccount[_to], "The Reciever Account is Frozen");
        // check if the account is freezed
        checker(_to, _value);

        super.transferFrom(_from, _to, _value);
    }

    /**
    * @dev function for checking parameters and requires
    * @param _to address for the reciever
    * @param _value the amount of token
    */
    function checker(address _to, uint256 _value) internal {
        // check for roles
        if (hasRole(_to, "Advisor")) {
            require(advisorCap >= totalTransferToAdvisor, "Remaining tokens for Advisor Exceeds the Cap allocated for Advisors Only");
            totalTransferToAdvisor = totalTransferToAdvisor.add(_value);
        } else if (hasRole(_to, "Team")) {
            require(teamCap >= totalTransferToTeam, "Remaining tokens for Team Exceeds the Cap allocated for Team Only");
            totalTransferToTeam = totalTransferToTeam.add(_value);
        } else if (hasRole(_to, "Sales")) {
            require(salesCap >= totalTransferToSales, "Remaining tokens for Sales Exceeds the Cap allocated for Sales Only");
            totalTransferToSales = totalTransferToSales.add(_value);
        } else if (hasRole(_to, "Reserved")) {
            require(reservedCap >= totalTransferToReserved, "Remaining tokens for Reserved Exceeds the Cap allocated for Reserved Only");
            totalTransferToReserved = totalTransferToReserved.add(_value);
        } else if (hasRole(_to, "Bonus")) {
            require(bonusCap >= totalTransferToBonus, "Remaining tokens for Bonus Exceeds the Cap allocated for Bonus Only");
            totalTransferToBonus = totalTransferToBonus.add(_value);
        }
    }
}