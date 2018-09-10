pragma solidity ^0.4.24;

// File: node_modules\openzeppelin-solidity\contracts\math\SafeMath.sol

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
    // Gas optimization: this is cheaper than asserting 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (_a == 0) {
      return 0;
    }

    c = _a * _b;
    assert(c / _a == _b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
    // assert(_b > 0); // Solidity automatically throws when dividing by 0
    // uint256 c = _a / _b;
    // assert(_a == _b * c + _a % _b); // There is no case in which this doesn't hold
    return _a / _b;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
    assert(_b <= _a);
    return _a - _b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
    c = _a + _b;
    assert(c >= _a);
    return c;
  }
}

// File: node_modules\openzeppelin-solidity\contracts\token\ERC20\ERC20Basic.sol

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * See https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address _who) public view returns (uint256);
  function transfer(address _to, uint256 _value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

// File: node_modules\openzeppelin-solidity\contracts\token\ERC20\ERC20.sol

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address _owner, address _spender)
    public view returns (uint256);

  function transferFrom(address _from, address _to, uint256 _value)
    public returns (bool);

  function approve(address _spender, uint256 _value) public returns (bool);
  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}

// File: node_modules\openzeppelin-solidity\contracts\token\ERC20\SafeERC20.sol

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
  function safeTransfer(
    ERC20Basic _token,
    address _to,
    uint256 _value
  )
    internal
  {
    require(_token.transfer(_to, _value));
  }

  function safeTransferFrom(
    ERC20 _token,
    address _from,
    address _to,
    uint256 _value
  )
    internal
  {
    require(_token.transferFrom(_from, _to, _value));
  }

  function safeApprove(
    ERC20 _token,
    address _spender,
    uint256 _value
  )
    internal
  {
    require(_token.approve(_spender, _value));
  }
}

// File: node_modules\openzeppelin-solidity\contracts\crowdsale\Crowdsale.sol

/**
 * @title Crowdsale
 * @dev Crowdsale is a base contract for managing a token crowdsale,
 * allowing investors to purchase tokens with ether. This contract implements
 * such functionality in its most fundamental form and can be extended to provide additional
 * functionality and/or custom behavior.
 * The external interface represents the basic interface for purchasing tokens, and conform
 * the base architecture for crowdsales. They are *not* intended to be modified / overridden.
 * The internal interface conforms the extensible and modifiable surface of crowdsales. Override
 * the methods to add functionality. Consider using 'super' where appropriate to concatenate
 * behavior.
 */
contract Crowdsale {
  using SafeMath for uint256;
  using SafeERC20 for ERC20;

  // The token being sold
  ERC20 public token;

  // Address where funds are collected
  address public wallet;

  // How many token units a buyer gets per wei.
  // The rate is the conversion between wei and the smallest and indivisible token unit.
  // So, if you are using a rate of 1 with a DetailedERC20 token with 3 decimals called TOK
  // 1 wei will give you 1 unit, or 0.001 TOK.
  uint256 public rate;

  // Amount of wei raised
  uint256 public weiRaised;

  /**
   * Event for token purchase logging
   * @param purchaser who paid for the tokens
   * @param beneficiary who got the tokens
   * @param value weis paid for purchase
   * @param amount amount of tokens purchased
   */
  event TokenPurchase(
    address indexed purchaser,
    address indexed beneficiary,
    uint256 value,
    uint256 amount
  );

  /**
   * @param _rate Number of token units a buyer gets per wei
   * @param _wallet Address where collected funds will be forwarded to
   * @param _token Address of the token being sold
   */
  constructor(uint256 _rate, address _wallet, ERC20 _token) public {
    require(_rate > 0);
    require(_wallet != address(0));
    require(_token != address(0));

    rate = _rate;
    wallet = _wallet;
    token = _token;
  }

  // -----------------------------------------
  // Crowdsale external interface
  // -----------------------------------------

  /**
   * @dev fallback function ***DO NOT OVERRIDE***
   */
  function () external payable {
    buyTokens(msg.sender);
  }

  /**
   * @dev low level token purchase ***DO NOT OVERRIDE***
   * @param _beneficiary Address performing the token purchase
   */
  function buyTokens(address _beneficiary) public payable {

    uint256 weiAmount = msg.value;
    _preValidatePurchase(_beneficiary, weiAmount);

    // calculate token amount to be created
    uint256 tokens = _getTokenAmount(weiAmount);

    // update state
    weiRaised = weiRaised.add(weiAmount);

    _processPurchase(_beneficiary, tokens);
    emit TokenPurchase(
      msg.sender,
      _beneficiary,
      weiAmount,
      tokens
    );

    _updatePurchasingState(_beneficiary, weiAmount);

    _forwardFunds();
    _postValidatePurchase(_beneficiary, weiAmount);
  }

  // -----------------------------------------
  // Internal interface (extensible)
  // -----------------------------------------

  /**
   * @dev Validation of an incoming purchase. Use require statements to revert state when conditions are not met. Use `super` in contracts that inherit from Crowdsale to extend their validations.
   * Example from CappedCrowdsale.sol's _preValidatePurchase method: 
   *   super._preValidatePurchase(_beneficiary, _weiAmount);
   *   require(weiRaised.add(_weiAmount) <= cap);
   * @param _beneficiary Address performing the token purchase
   * @param _weiAmount Value in wei involved in the purchase
   */
  function _preValidatePurchase(
    address _beneficiary,
    uint256 _weiAmount
  )
    internal
  {
    require(_beneficiary != address(0));
    require(_weiAmount != 0);
  }

  /**
   * @dev Validation of an executed purchase. Observe state and use revert statements to undo rollback when valid conditions are not met.
   * @param _beneficiary Address performing the token purchase
   * @param _weiAmount Value in wei involved in the purchase
   */
  function _postValidatePurchase(
    address _beneficiary,
    uint256 _weiAmount
  )
    internal
  {
    // optional override
  }

  /**
   * @dev Source of tokens. Override this method to modify the way in which the crowdsale ultimately gets and sends its tokens.
   * @param _beneficiary Address performing the token purchase
   * @param _tokenAmount Number of tokens to be emitted
   */
  function _deliverTokens(
    address _beneficiary,
    uint256 _tokenAmount
  )
    internal
  {
    token.safeTransfer(_beneficiary, _tokenAmount);
  }

  /**
   * @dev Executed when a purchase has been validated and is ready to be executed. Not necessarily emits/sends tokens.
   * @param _beneficiary Address receiving the tokens
   * @param _tokenAmount Number of tokens to be purchased
   */
  function _processPurchase(
    address _beneficiary,
    uint256 _tokenAmount
  )
    internal
  {
    _deliverTokens(_beneficiary, _tokenAmount);
  }

  /**
   * @dev Override for extensions that require an internal state to check for validity (current user contributions, etc.)
   * @param _beneficiary Address receiving the tokens
   * @param _weiAmount Value in wei involved in the purchase
   */
  function _updatePurchasingState(
    address _beneficiary,
    uint256 _weiAmount
  )
    internal
  {
    // optional override
  }

  /**
   * @dev Override to extend the way in which ether is converted to tokens.
   * @param _weiAmount Value in wei to be converted into tokens
   * @return Number of tokens that can be purchased with the specified _weiAmount
   */
  function _getTokenAmount(uint256 _weiAmount)
    internal view returns (uint256)
  {
    return _weiAmount.mul(rate);
  }

  /**
   * @dev Determines how ETH is stored/forwarded on purchases.
   */
  function _forwardFunds() internal {
    wallet.transfer(msg.value);
  }
}

// File: node_modules\openzeppelin-solidity\contracts\crowdsale\validation\TimedCrowdsale.sol

/**
 * @title TimedCrowdsale
 * @dev Crowdsale accepting contributions only within a time frame.
 */
contract TimedCrowdsale is Crowdsale {
  using SafeMath for uint256;

  uint256 public openingTime;
  uint256 public closingTime;

  /**
   * @dev Reverts if not in crowdsale time range.
   */
  modifier onlyWhileOpen {
    // solium-disable-next-line security/no-block-members
    require(block.timestamp >= openingTime && block.timestamp <= closingTime);
    _;
  }

  /**
   * @dev Constructor, takes crowdsale opening and closing times.
   * @param _openingTime Crowdsale opening time
   * @param _closingTime Crowdsale closing time
   */
  constructor(uint256 _openingTime, uint256 _closingTime) public {
    // solium-disable-next-line security/no-block-members
    require(_openingTime >= block.timestamp);
    require(_closingTime >= _openingTime);

    openingTime = _openingTime;
    closingTime = _closingTime;
  }

  /**
   * @dev Checks whether the period in which the crowdsale is open has already elapsed.
   * @return Whether crowdsale period has elapsed
   */
  function hasClosed() public view returns (bool) {
    // solium-disable-next-line security/no-block-members
    return block.timestamp > closingTime;
  }

  /**
   * @dev Extend parent behavior requiring to be within contributing period
   * @param _beneficiary Token purchaser
   * @param _weiAmount Amount of wei contributed
   */
  function _preValidatePurchase(
    address _beneficiary,
    uint256 _weiAmount
  )
    internal
    onlyWhileOpen
  {
    super._preValidatePurchase(_beneficiary, _weiAmount);
  }

}

// File: node_modules\openzeppelin-solidity\contracts\ownership\Ownable.sol

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() public {
    owner = msg.sender;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  /**
   * @dev Allows the current owner to relinquish control of the contract.
   * @notice Renouncing to ownership will leave the contract without an owner.
   * It will not be possible to call the functions with the `onlyOwner`
   * modifier anymore.
   */
  function renounceOwnership() public onlyOwner {
    emit OwnershipRenounced(owner);
    owner = address(0);
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function transferOwnership(address _newOwner) public onlyOwner {
    _transferOwnership(_newOwner);
  }

  /**
   * @dev Transfers control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function _transferOwnership(address _newOwner) internal {
    require(_newOwner != address(0));
    emit OwnershipTransferred(owner, _newOwner);
    owner = _newOwner;
  }
}

// File: node_modules\openzeppelin-solidity\contracts\access\rbac\Roles.sol

/**
 * @title Roles
 * @author Francisco Giordano (@frangio)
 * @dev Library for managing addresses assigned to a Role.
 * See RBAC.sol for example usage.
 */
library Roles {
  struct Role {
    mapping (address => bool) bearer;
  }

  /**
   * @dev give an address access to this role
   */
  function add(Role storage _role, address _addr)
    internal
  {
    _role.bearer[_addr] = true;
  }

  /**
   * @dev remove an address' access to this role
   */
  function remove(Role storage _role, address _addr)
    internal
  {
    _role.bearer[_addr] = false;
  }

  /**
   * @dev check if an address has this role
   * // reverts
   */
  function check(Role storage _role, address _addr)
    internal
    view
  {
    require(has(_role, _addr));
  }

  /**
   * @dev check if an address has this role
   * @return bool
   */
  function has(Role storage _role, address _addr)
    internal
    view
    returns (bool)
  {
    return _role.bearer[_addr];
  }
}

// File: node_modules\openzeppelin-solidity\contracts\access\rbac\RBAC.sol

/**
 * @title RBAC (Role-Based Access Control)
 * @author Matt Condon (@Shrugs)
 * @dev Stores and provides setters and getters for roles and addresses.
 * Supports unlimited numbers of roles and addresses.
 * See //contracts/mocks/RBACMock.sol for an example of usage.
 * This RBAC method uses strings to key roles. It may be beneficial
 * for you to write your own implementation of this interface using Enums or similar.
 */
contract RBAC {
  using Roles for Roles.Role;

  mapping (string => Roles.Role) private roles;

  event RoleAdded(address indexed operator, string role);
  event RoleRemoved(address indexed operator, string role);

  /**
   * @dev reverts if addr does not have role
   * @param _operator address
   * @param _role the name of the role
   * // reverts
   */
  function checkRole(address _operator, string _role)
    public
    view
  {
    roles[_role].check(_operator);
  }

  /**
   * @dev determine if addr has role
   * @param _operator address
   * @param _role the name of the role
   * @return bool
   */
  function hasRole(address _operator, string _role)
    public
    view
    returns (bool)
  {
    return roles[_role].has(_operator);
  }

  /**
   * @dev add a role to an address
   * @param _operator address
   * @param _role the name of the role
   */
  function addRole(address _operator, string _role)
    internal
  {
    roles[_role].add(_operator);
    emit RoleAdded(_operator, _role);
  }

  /**
   * @dev remove a role from an address
   * @param _operator address
   * @param _role the name of the role
   */
  function removeRole(address _operator, string _role)
    internal
  {
    roles[_role].remove(_operator);
    emit RoleRemoved(_operator, _role);
  }

  /**
   * @dev modifier to scope access to a single role (uses msg.sender as addr)
   * @param _role the name of the role
   * // reverts
   */
  modifier onlyRole(string _role)
  {
    checkRole(msg.sender, _role);
    _;
  }

  /**
   * @dev modifier to scope access to a set of roles (uses msg.sender as addr)
   * @param _roles the names of the roles to scope access to
   * // reverts
   *
   * @TODO - when solidity supports dynamic arrays as arguments to modifiers, provide this
   *  see: https://github.com/ethereum/solidity/issues/2467
   */
  // modifier onlyRoles(string[] _roles) {
  //     bool hasAnyRole = false;
  //     for (uint8 i = 0; i < _roles.length; i++) {
  //         if (hasRole(msg.sender, _roles[i])) {
  //             hasAnyRole = true;
  //             break;
  //         }
  //     }

  //     require(hasAnyRole);

  //     _;
  // }
}

// File: node_modules\openzeppelin-solidity\contracts\access\Whitelist.sol

/**
 * @title Whitelist
 * @dev The Whitelist contract has a whitelist of addresses, and provides basic authorization control functions.
 * This simplifies the implementation of "user permissions".
 */
contract Whitelist is Ownable, RBAC {
  string public constant ROLE_WHITELISTED = "whitelist";

  /**
   * @dev Throws if operator is not whitelisted.
   * @param _operator address
   */
  modifier onlyIfWhitelisted(address _operator) {
    checkRole(_operator, ROLE_WHITELISTED);
    _;
  }

  /**
   * @dev add an address to the whitelist
   * @param _operator address
   * @return true if the address was added to the whitelist, false if the address was already in the whitelist
   */
  function addAddressToWhitelist(address _operator)
    public
    onlyOwner
  {
    addRole(_operator, ROLE_WHITELISTED);
  }

  /**
   * @dev getter to determine if address is in whitelist
   */
  function whitelist(address _operator)
    public
    view
    returns (bool)
  {
    return hasRole(_operator, ROLE_WHITELISTED);
  }

  /**
   * @dev add addresses to the whitelist
   * @param _operators addresses
   * @return true if at least one address was added to the whitelist,
   * false if all addresses were already in the whitelist
   */
  function addAddressesToWhitelist(address[] _operators)
    public
    onlyOwner
  {
    for (uint256 i = 0; i < _operators.length; i++) {
      addAddressToWhitelist(_operators[i]);
    }
  }

  /**
   * @dev remove an address from the whitelist
   * @param _operator address
   * @return true if the address was removed from the whitelist,
   * false if the address wasn't in the whitelist in the first place
   */
  function removeAddressFromWhitelist(address _operator)
    public
    onlyOwner
  {
    removeRole(_operator, ROLE_WHITELISTED);
  }

  /**
   * @dev remove addresses from the whitelist
   * @param _operators addresses
   * @return true if at least one address was removed from the whitelist,
   * false if all addresses weren't in the whitelist in the first place
   */
  function removeAddressesFromWhitelist(address[] _operators)
    public
    onlyOwner
  {
    for (uint256 i = 0; i < _operators.length; i++) {
      removeAddressFromWhitelist(_operators[i]);
    }
  }

}

// File: node_modules\openzeppelin-solidity\contracts\crowdsale\distribution\FinalizableCrowdsale.sol

/**
 * @title FinalizableCrowdsale
 * @dev Extension of Crowdsale where an owner can do extra work
 * after finishing.
 */
contract FinalizableCrowdsale is Ownable, TimedCrowdsale {
  using SafeMath for uint256;

  bool public isFinalized = false;

  event Finalized();

  /**
   * @dev Must be called after crowdsale ends, to do some extra finalization
   * work. Calls the contract's finalization function.
   */
  function finalize() public onlyOwner {
    require(!isFinalized);
    require(hasClosed());

    finalization();
    emit Finalized();

    isFinalized = true;
  }

  /**
   * @dev Can be overridden to add finalization logic. The overriding function
   * should call super.finalization() to ensure the chain of finalization is
   * executed entirely.
   */
  function finalization() internal {
  }

}

// File: node_modules\openzeppelin-solidity\contracts\token\ERC20\BasicToken.sol

/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) internal balances;

  uint256 internal totalSupply_;

  /**
  * @dev Total number of tokens in existence
  */
  function totalSupply() public view returns (uint256) {
    return totalSupply_;
  }

  /**
  * @dev Transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_value <= balances[msg.sender]);
    require(_to != address(0));

    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    emit Transfer(msg.sender, _to, _value);
    return true;
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) public view returns (uint256) {
    return balances[_owner];
  }

}

// File: node_modules\openzeppelin-solidity\contracts\token\ERC20\StandardToken.sol

/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * https://github.com/ethereum/EIPs/issues/20
 * Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) internal allowed;


  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
  function transferFrom(
    address _from,
    address _to,
    uint256 _value
  )
    public
    returns (bool)
  {
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);
    require(_to != address(0));

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    emit Transfer(_from, _to, _value);
    return true;
  }

  /**
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
   * Beware that changing an allowance with this method brings the risk that someone may use both the old
   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
   * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param _owner address The address which owns the funds.
   * @param _spender address The address which will spend the funds.
   * @return A uint256 specifying the amount of tokens still available for the spender.
   */
  function allowance(
    address _owner,
    address _spender
   )
    public
    view
    returns (uint256)
  {
    return allowed[_owner][_spender];
  }

  /**
   * @dev Increase the amount of tokens that an owner allowed to a spender.
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _addedValue The amount of tokens to increase the allowance by.
   */
  function increaseApproval(
    address _spender,
    uint256 _addedValue
  )
    public
    returns (bool)
  {
    allowed[msg.sender][_spender] = (
      allowed[msg.sender][_spender].add(_addedValue));
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  /**
   * @dev Decrease the amount of tokens that an owner allowed to a spender.
   * approve should be called when allowed[_spender] == 0. To decrement
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _subtractedValue The amount of tokens to decrease the allowance by.
   */
  function decreaseApproval(
    address _spender,
    uint256 _subtractedValue
  )
    public
    returns (bool)
  {
    uint256 oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue >= oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

}

// File: node_modules\openzeppelin-solidity\contracts\lifecycle\Pausable.sol

/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is Ownable {
  event Pause();
  event Unpause();

  bool public paused = false;


  /**
   * @dev Modifier to make a function callable only when the contract is not paused.
   */
  modifier whenNotPaused() {
    require(!paused);
    _;
  }

  /**
   * @dev Modifier to make a function callable only when the contract is paused.
   */
  modifier whenPaused() {
    require(paused);
    _;
  }

  /**
   * @dev called by the owner to pause, triggers stopped state
   */
  function pause() public onlyOwner whenNotPaused {
    paused = true;
    emit Pause();
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function unpause() public onlyOwner whenPaused {
    paused = false;
    emit Unpause();
  }
}

// File: node_modules\openzeppelin-solidity\contracts\token\ERC20\PausableToken.sol

/**
 * @title Pausable token
 * @dev StandardToken modified with pausable transfers.
 **/
contract PausableToken is StandardToken, Pausable {

  function transfer(
    address _to,
    uint256 _value
  )
    public
    whenNotPaused
    returns (bool)
  {
    return super.transfer(_to, _value);
  }

  function transferFrom(
    address _from,
    address _to,
    uint256 _value
  )
    public
    whenNotPaused
    returns (bool)
  {
    return super.transferFrom(_from, _to, _value);
  }

  function approve(
    address _spender,
    uint256 _value
  )
    public
    whenNotPaused
    returns (bool)
  {
    return super.approve(_spender, _value);
  }

  function increaseApproval(
    address _spender,
    uint _addedValue
  )
    public
    whenNotPaused
    returns (bool success)
  {
    return super.increaseApproval(_spender, _addedValue);
  }

  function decreaseApproval(
    address _spender,
    uint _subtractedValue
  )
    public
    whenNotPaused
    returns (bool success)
  {
    return super.decreaseApproval(_spender, _subtractedValue);
  }
}

// File: node_modules\openzeppelin-solidity\contracts\token\ERC20\MintableToken.sol

/**
 * @title Mintable token
 * @dev Simple ERC20 Token example, with mintable token creation
 * Based on code by TokenMarketNet: https://github.com/TokenMarketNet/ico/blob/master/contracts/MintableToken.sol
 */
contract MintableToken is StandardToken, Ownable {
  event Mint(address indexed to, uint256 amount);
  event MintFinished();

  bool public mintingFinished = false;


  modifier canMint() {
    require(!mintingFinished);
    _;
  }

  modifier hasMintPermission() {
    require(msg.sender == owner);
    _;
  }

  /**
   * @dev Function to mint tokens
   * @param _to The address that will receive the minted tokens.
   * @param _amount The amount of tokens to mint.
   * @return A boolean that indicates if the operation was successful.
   */
  function mint(
    address _to,
    uint256 _amount
  )
    public
    hasMintPermission
    canMint
    returns (bool)
  {
    totalSupply_ = totalSupply_.add(_amount);
    balances[_to] = balances[_to].add(_amount);
    emit Mint(_to, _amount);
    emit Transfer(address(0), _to, _amount);
    return true;
  }

  /**
   * @dev Function to stop minting new tokens.
   * @return True if the operation was successful.
   */
  function finishMinting() public onlyOwner canMint returns (bool) {
    mintingFinished = true;
    emit MintFinished();
    return true;
  }
}

// File: contracts\TrainDanyToken.sol

// solium-disable linebreak-style
pragma solidity ^0.4.24;

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

// File: contracts\TrainDanyCrowdsale.sol

// solium-disable linebreak-style
pragma solidity ^0.4.24;

contract TrainDanyCrowdsale is FinalizableCrowdsale {
    // TODO: Whitelisted applying on Stages
    // TODO: Change opening date and closing date
    // TODO: calculate Bonus

    // TODO: Time crowdsale depending on sales stage

    // ICO Stages ==========================================
    enum CrowdsaleStage { PrivateSale, PreSale, PublicSale }        // All 3 Sale Stages
    CrowdsaleStage private stage;                                   // the sale stages

    // Token Distribution
    // ====================================================
    uint256 public maxTokens = 625000000000000000;                          // There will be total 4000000000 TDY Tokens
    uint256 public tokensForSales = 400000000000000000;
    uint256 public tokensForTeam = 62500000000000000;
    uint256 public tokensForBonus = 18750000000000000;
    uint256 public tokenForAdvisor = 50000000000000000;
    uint256 public totalTokensForSale = 400000000000000000;                 // 64 TDY Token will be sold in Crowdsale
    uint256 public totalTokensForSaleDuringPrivatesale = 62500000000000000; // 20 out of 60 HTs will be sold during PreICO
    uint256 public totalTokensForSaleDuringPresale = 62500000000000000;
    uint256 public totalTokensForSaleDuringPublicsale = 187500000000000000;

    // Amount raised in Crowdsale
    // ===================================================
    uint256 public totalWeiRaisedDuringSale; // funding goal in wei 15625000000000000000000
    // ===================================================

    uint256 public minimumInvest;
    uint256 public bonus;
    // Events
    event EthTransferred(string text);
    event EthRefunded(string text);

    // Constructor
    // ============
    constructor(uint _stageValue, uint256 _startTime, uint256 _endTime, uint256 _rate, address _wallet, TrainDanyToken _trainDanyToken) Crowdsale(_rate, _wallet, _trainDanyToken) public {
        // set crrowdsale
        setCrowdsaleStage(_stageValue);
    }
    // =============

    // Token Deployment
    // =================
    function createTokenContract() internal returns (MintableToken) {
        return new TrainDanyToken(); // Deploys the ERC20 token. Automatically called when crowdsale contract is deployed
    }
    // ==================

    // Crowdsale Stage Management
    // =========================================================
    
    // Change Crowdsale Stage. Available Options: PreICO, ICO
    function setCrowdsaleStage(uint _value) public onlyOwner {
        // check if existing crowdsale ends
        // chnage stages and initialize according to input
        // private sale
        CrowdsaleStage _stage;
        if (_value == uint(CrowdsaleStage.PrivateSale)) {
            stage = _stage;
            // chnage minimum invest
            minimumInvest = 250 ether;
            // change bonus
            bonus = 5000;
            // chnage token sales cap
            // change start and end time
        } else if (_value == uint(CrowdsaleStage.PreSale)) {
            stage = _stage;
            minimumInvest = 0.1 ether;
            bonus = 3000;
        } else if (_value == uint(CrowdsaleStage.PublicSale)) {
            stage = _stage;
            minimumInvest = 0.1 ether;
            // check time and apply bonus
            bonus = 2000;
        }
    }

    // ================ Stage Management Over =====================

    // Token Purchase
    // =========================
    function () external payable {
        // check for sales time 
        // calculate bonus
        uint256 tokensThatWillBeMintedAfterPurchase = msg.value.mul(rate);
        if ((stage == CrowdsaleStage.PrivateSale) && (token.totalSupply() + tokensThatWillBeMintedAfterPurchase > totalTokensForSaleDuringPrivatesale)) {
        // msg.sender.transfer(msg.value); // Refund them
        
            emit EthRefunded("Private sale Limit Hit");
            return;
        }

        buyTokens(msg.sender);

        if (stage == CrowdsaleStage.PrivateSale) {
            totalWeiRaisedDuringSale = totalWeiRaisedDuringSale.add(msg.value);
        }
    }

    function forwardFunds() internal {
        if (stage == CrowdsaleStage.PrivateSale) {
            wallet.transfer(msg.value);
            emit EthTransferred("forwarding funds to wallet");
        } 
        // else if (stage == CrowdsaleStage.ICO) {
        //     EthTransferred("forwarding funds to refundable vault");
        //     super.forwardFunds();
        // }
    }
    // ===========================

    // Finish: Mint Extra Tokens as needed before finalizing the Crowdsale.
    // ====================================================================

    function finish(address _teamFund, address _ecosystemFund, address _bountyFund) public onlyOwner {

        require(!isFinalized);
        uint256 alreadyMinted = token.totalSupply();
        require(alreadyMinted < maxTokens);

        // uint256 unsoldTokens = tokensForSales - alreadyMinted;
        // if (unsoldTokens > 0) {
        //     tokensForEcosystem = tokensForEcosystem + unsoldTokens;
        // }

        // token.mint(_teamFund,tokensForTeam);
        // token.mint(_ecosystemFund,tokenForAdvisor);
        // token.mint(_bountyFund,tokensForBonus);
        // finalize();
    }
    // ===============================

    // REMOVE THIS FUNCTION ONCE YOU ARE READY FOR PRODUCTION
    // USEFUL FOR TESTING `finish()` FUNCTION
    function hasEnded() public view returns (bool) {
        return true;
    }
    // uint256 private startTime;                                      // Unix Epoch Time 1536105600 @ September 5, 2018 12:00:00 AM 
    // uint256 private endTime;                                        // Unix Epoch Time  1537833600 @ September 25, 2018 12:00:00 AM


    // uint256 public totalTokenForSaleCrowdsale;
    // TrainDanyToken private _token;

    // // Constructor
    // // ====================================================
    // constructor(uint256 _startTime, uint256 _endTime, uint256 _rate, address _wallet) 
    //     Crowdsale(_rate, _wallet, _token) 
    //     public {
    //     require(_startTime >= now);
    //     // start a sale setCrowdsaleStage
    // }
    // // ====================================================

    // // Crowdsale Stage Management
    // // ====================================================
    // // change crowdsale stages 
    // // Availbale Options : PrivateSale, PreSale, PublicSale
    // // ====================================================
    // function setCrowdsaleStage (uint _value) public onlyOwner {
       
    // }

    // function changeSalesTime() public onlyOwner {
    //     // change sales time
    // }

    
    // TrainDanyToken private trainDanyToken;                          // The actual token contract for the TDY
    // ERC20 private token;                                            // The ERC20 TDY Token Contract  
    // address private wallet;                                         // Address where funds are collected "0x1406335646bf1fca47c9d08925f59c3f46b50276"
    // // How many token units a buyer gets per wei.
    // // The rate is the conversion between wei and the smallest and indivisible token unit.
    // // So, if you are using a rate of 1 with a DetailedERC20 token with 3 decimals called TOK
    // // 1 wei will give you 1 unit, or 0.001 TOK.
    // uint256 public rate;  // 25000000000000 wei will provide 1 TDY token
    

    // // bool private privatesale = false;
    // // bool private presale = false;
    // // bool private publicsale = false;                                      
    // // uint private bonus; // bonus multiplier for the sale
    // // uint private minimumInvest; // Minimum invest cap for the investors

    

    // function initializeCrowdsale(uint _stageValue, uint256 _startTime, uint256 _endTime) public onlyOwner {
    //     // check if current crowdsale is finished
    //     if (_stageValue == uint(CrowdsaleStage.Privatesale) && !presale && !publicsale) {
    //         startTime = _startTime;
    //         endTime = _endTime;
    //         stage = CrowdsaleStage.Privatesale;
    //         setCurrentStage(stage, startTime, endTime);
    //     } else if (_stageValue == uint(CrowdsaleStage.Presale) && !privatesale && !publicsale) {
    //         startTime = _startTime;
    //         endTime = _endTime;
    //         stage = CrowdsaleStage.Presale;
    //         setCurrentStage(stage, startTime, endTime);
    //     } else if (_stageValue == uint(CrowdsaleStage.Publicsale) && !privatesale && !presale) {
    //         startTime = _startTime;
    //         endTime = _endTime;
    //         stage = CrowdsaleStage.Publicsale;
    //         setCurrentStage(stage, startTime, endTime);
    //     }
    // }
 
    // function getCurrentSaleStage() public view returns(string) {
    //     // TODO: add also time line
    //     if (stage == CrowdsaleStage.Privatesale){
    //         return "Private Sale";
    //     } else if (stage == CrowdsaleStage.Presale) {
    //         return "Pre sale";
    //     } else if (stage == CrowdsaleStage.Publicsale) {
    //         return "Public sale";
    //     } else if (stage == Null){
    //         return "No Sale has been started";
    //     }
    // }

    // function getCurrentBonus () public view returns(uint) {
    //     return bonus;
    // }

    // function setCurrentStage(Crowdsale _stage, uint256 _startTime, uint256 _endTime) public onlyOwner {
        
    //     if (_stage == CrowdsaleStage.publicsale){
    //         // set bonus multiplier
    //         require ( now >= startime && now <= endtime);
    //         if (startTime <= startTime + 1 weeks) {
    //             bonus = 2000;
    //         } else if (startTime >= startTime + 2 weeks) {
    //             bonus = 1000;
    //         } else if (startTime <= startTime + 3 weeks) {
    //             bonus = 500;
    //         } else if (startTime <= startTime + 4 weeks) {
    //             bonus = 0;
    //         }
    //         // set minimum invest
    //         minimumInvest = 0.1 ether;
    //         // set time

    //         // set flag
    //         publicsale = true;
    //         privatesale = false;
    //         presale = false;

    //     } else if (stage == CrowdsaleStage.presale) {
    //         bonus = 3000;
    //         minimumInvest = 0.1 ether;
    //         publicsale = false;
    //         privatesale = false;
    //         presale = true;
    //     } else if (stage == CrowdsaleStage.privatesale) {
    //         bonus = 5000;
    //         minimumInvest = 250 ether;
    //         publicsale = false;
    //         privatesale = true;
    //         presale = false;
    //     }

    // }

    // // Auto finalize crowdsale

    // // 
    // // uint32[] public BONUS_TIMES;
    // // uint32[] public BONUS_TIMES_VALUES;
    // // uint32[] public BONUS_AMOUNTS;
    // // uint32[] public BONUS_AMOUNTS_VALUES;
    // // uint public constant BONUS_COEFF = 1000; // Values should be 10x percents, values from 0 to 1000
    // // ================ Initialize ================================
    // // ================ Stage Management Over =====================
    // // ================ Finalization ==============================
    // // Change Crowdsale Stage. Available Options: Privatesale, Presale, Publicsale
   



    // uint256 private _rate = 40000; // 1 ETH = 40000 TDY Token
    // address private _wallet; // = ; address of the beneficiary
    // ERC20 private _tokenContract; 

    // uint256 public minimalInvestmentInWei = 5 ether;
    // address public tokenAddress;
    // uint256 private tokenPrice;

    // TrainDanyToken public trainDanyToken;

    // event InitialDateReset(uint256 startTime, uint256 endTime);
    // event InitialRateChange(uint256 rate, uint256 cap, uint256 minimalInvestment);

    // // uint256 _rate, address _wallet, ERC20 _token


    // // Constructor
    // constructor(uint256 _startTime, uint256 _endTime) 
    //     Crowdsale(_rate, _wallet, _token) TimedCrowdsale(startTime, endTime) public {

    // }
    // // bonus multiplie according to time (weeks)

    // // time reset machanism
    // /**
    // * @dev Reset start and end date/time for this Presale.
    // * @param _startTime change presale start time
    // * @param _endTime change presale end period
    // */
    // function setSaleDates(uint256 _startTime, uint256 _endTime) public onlyOwner returns (bool) { 
    //     require(startTime > block.timestamp);
    //     require(_startTime >= now);
    //     require(_endTime >= _startTime);

    //     startTime = _startTime;
    //     endTime = _endTime;

    //     InitialDateReset(startTime, endTime);
    //     return true;
    // }

    // /**
    // * @dev Sets the token conversion rate
    // * @param _rateInWei - Price of 1 Binkd token in Wei. 
    // * @param _capInWei - Cap of the Presale in Wei. 
    // * @param _minimalInvestmentInWei - Minimal investment in Wei. 
    // */
    // function setRate(uint256 _rateInWei, uint256 _capInWei, uint256 _minimalInvestmentInWei) public onlyOwner returns (bool) { 
    //     require(startTime >= block.timestamp); // can't update anymore if sale already started
    //     require(_rateInWei > 0);
    //     require(_capInWei > 0);
    //     require(_minimalInvestmentInWei > 0);

    //     rate = _rateInWei;
    //     cap = _capInWei;
    //     minimalInvestmentInWei = _minimalInvestmentInWei;

    //     InitialRateChange(rate, cap, minimalInvestmentInWei);
    //     return true;
    // }

    // // set the token owner to contract owner
    // function reTransferTokenOwnership() onlyOwner public { 
    //     TrainDanyToken.transferOwnership(owner);
    // }
}
