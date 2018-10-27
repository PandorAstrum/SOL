// solium-disable linebreak-style
pragma solidity ^0.4.24;

import "./../node_modules/openzeppelin-solidity/contracts/crowdsale/distribution/FinalizableCrowdsale.sol";
import "./../node_modules/openzeppelin-solidity/contracts/access/Whitelist.sol";

/**
 * @title TrainDany Crowdsale - This is the Crowdsale contract for TrainDany Token
 * @dev TrainDanyCrowdsale is a Finalizable Crowdsale With Timed Crowdsale and Whitelist for (KYC)
 * Crowdsale Stage can be change along with time at later date upon initialization date
 * `TimedCrowdsale` functions.
 * `Finalizeable` functions.
 * `Whitelist` functions.
 * Total Sellable Token would be 4 000 000 000 TDY Tokens (64%)
 * Presale participants would be offered 30% extra tokens as bonus
 * Private participants would be offered 50% extra tokens as bonus
 * Crowdsale participants would be offered 20%, 10%, 5%, No bunus on respective weeks from start
 * Unsold TDY tokens can not be burnt or minted before and after the sales
 * the rate is fixed 40000 TDY token for 1 Ether
 */
contract TrainDanyCrowdsale is FinalizableCrowdsale, Whitelist {
    // TODO: Finalize crowdsale (do extra work)
    // TODO: token calculations
    // TODO: transfer token and and eth goes to owner

    uint256 public rate = 40000;                                    // fixed rate for 1 ETHER = 40000 TDY Token
    uint256 public openingTime;                                     // Sales Opening Time
    uint256 public closingTime;                                     // Sales Closing Time

    // ICO Stages ==========================================
    enum CrowdsaleStage { PrivateSale, PreSale, PublicSale }        // All 3 Sale Stages
    CrowdsaleStage public stage;                                    // the sale stages
    bool private privateSalesEnd = false;                           // flags for tracking private sales
    bool private preSalesEnd = false;                               // flags for tracking pre sales
    bool private publicSalesEnd = false;                            // flags for tracking public sales

    uint256 public minimumInvest;                                   // minimum invest for investor
    uint256 public totalTokenAvailableInThisStage;                  // Token availbale for sell in this stage
    uint256 public totalTokenSoldinThisStage;                       // Tokens Sold 
    uint256 public bonusMultiplier;                                 // Bonus tokens rate multiplier x1000 (i.e. 1200 is 1.2 x 1000 = 120% x1000 = +20% bonus)
    bool public closed;                                             // Is a crowdsale stage closed?
    uint256 public tokensIssued;                                    // Amount of issued tokens

    mapping(address => uint256) public balances;                    // Map of all purchaiser's balances (doesn't include bounty amounts)

    /**
    * Event for token delivered logging
    * @param _receiver who receive the tokens
    * @param _amount amount of tokens sent
    */
    event TokenDelivered(address indexed _receiver, uint256 _amount);
    /**
    * Event for Date Changed logging
    * @param _startTime opening time for crowdsale
    * @param _endTime closing time for crowdsale
    */
    event InitialDateReset(uint256 _startTime, uint256 _endTime);

    // Token Distribution
    // ====================================================
    uint256 private maxTokens = 625000000000000000;                          // There will be total 4000000000 TDY Tokens
    uint256 private tokensForSales = 400000000000000000;
    uint256 private tokensForTeam = 62500000000000000;                       // half blocked for 1 year / half blocked for 2 years
    uint256 private tokensForBonus = 18750000000000000;
    uint256 private tokenForAdvisor = 50000000000000000;                     // blocked for 6 months
    uint256 private totalTokensForSaleDuringPrivatesale = 62500000000000000; // 20 out of 60 HTs will be sold during PreICO
    uint256 private totalTokensForSaleDuringPresale = 62500000000000000;
    uint256 private totalTokensForSaleDuringPublicsale = 187500000000000000;
    /**
    * @dev Constructor for Initializing the sales upon deployment
    * @param _startTime start time in unix epoch can be got from https://www.epochconverter.com/
    * @param _endTime end time in unix epoch can be got from https://www.epochconverter.com/
    * @param _wallet wallet address where the fund will be forwared upon purchases
    * @param _trainDanyToken train dany token contract address
    */
    constructor(uint256 _startTime, uint256 _endTime, address _wallet, ERC20 _trainDanyToken)
        Crowdsale(rate, _wallet, _trainDanyToken) 
        TimedCrowdsale(_startTime, _endTime)
        public {
        setCrowdsale(0, _startTime, _endTime);                      // starts the private sale
    }

    /**
    * @dev time reset machanism
    * @param _startTime change start time
    * @param _endTime change end time
    */
    function changeDates(uint256 _startTime, uint256 _endTime) public onlyOwner returns (bool) { 
        require(openingTime > block.timestamp);
        require(_startTime >= now);
        require(_endTime >= _startTime);

        openingTime = _startTime;
        closingTime = _endTime;

        emit InitialDateReset(openingTime, closingTime);
        return true;
    }

    /**
    * @dev functions for setting up the crowdsale stage
    * @param _stageValue numerical value of the crowdsale stages.
    * Available options are 0 = private sale, 1 = pre sale, 2 = public sale
    * @param _startTime unix epoch time can be got from https://www.epochconverter.com/
    * @param _endTime unix epoch time can be got from https://www.epochconverter.com/
    */
    function setCrowdsale(uint _stageValue, uint256 _startTime, uint256 _endTime) onlyOwner public returns(bool){
        require(_stageValue <= 2);
        require(_startTime >= now);
        require(_endTime > _startTime);

        openingTime = _startTime;
        closingTime = _endTime;
        
        if (_stageValue == uint(CrowdsaleStage.PrivateSale)) {
            stage = CrowdsaleStage.PrivateSale;
            minimumInvest = 250 ether;
            totalTokenAvailableInThisStage = 62500000000000000;
            bonusMultiplier = 1500;
            totalTokenSoldinThisStage = 0;
        } else if (_stageValue == uint(CrowdsaleStage.PreSale)) {
            stage = CrowdsaleStage.PreSale;
            minimumInvest = 0.1 ether;
            totalTokenAvailableInThisStage = 62500000000000000;
            bonusMultiplier = 1300;
            totalTokenSoldinThisStage = 0;
        } else if (_stageValue == uint(CrowdsaleStage.PublicSale)) {
            stage = CrowdsaleStage.PublicSale;
            minimumInvest = 0.1 ether;
            totalTokenAvailableInThisStage = 187500000000000000;
            bonusMultiplier = 1200;
            totalTokenSoldinThisStage = 0;
        }
        return true;
    }

    /**
    * @dev Closes the period in which the crowdsale stage is open.
    */
    function closeCrowdsale() public onlyOwner returns(bool){
        closed = true;
        finalizeStage();
        return true;
    }

    function finalizeStage() internal {
        // finalize the stage
        if (stage == CrowdsaleStage.PrivateSale) {
            privateSalesEnd = true;
            closed = false;
            setCrowdsale(1, now, closingTime);
        } else if (stage == CrowdsaleStage.PreSale) {
            preSalesEnd = true;
            closed = false;
            setCrowdsale(2, now, closingTime);
        } else if (stage == CrowdsaleStage.PublicSale) {
            publicSalesEnd = true;
            closed = false;
        }
        // mint token to adjust with parameters
        uint256 tokenNotSold = totalTokenAvailableInThisStage - totalTokenSoldinThisStage;
        if (tokenNotSold > totalTokenAvailableInThisStage) {
            // add tokens
        } 
    }
    // Token Purchase
    // ==============================================================================
    /**
    * @dev Overrides parent for extra logic and requirements before purchasing tokens.
    * @param _beneficiary Token purchaser
    * @param _weiAmount Amount of tokens purchased
    */
    function _preValidatePurchase(address _beneficiary, uint256 _weiAmount) internal {
        require(!hasClosed());                                                  // check if crowdslae is still opens
        require(totalTokenAvailableInThisStage >= totalTokenSoldinThisStage);   // check if all tokens sold out       
        require(msg.value >= minimumInvest);                                    // check minimum invest met

        super._preValidatePurchase(_beneficiary, _weiAmount);
    }

    /**
    * @dev Overrides parent by storing balances instead of issuing tokens right away.
    * @param _beneficiary Token purchaser
    * @param _tokenAmount Amount of tokens purchased
    */
    function _processPurchase(address _beneficiary, uint256 _tokenAmount) internal {
        balances[_beneficiary] = balances[_beneficiary].add(_tokenAmount);
        totalTokenSoldinThisStage = totalTokenSoldinThisStage.add(_tokenAmount);
    }

    /**
    * @dev Overrides the way in which ether is converted to tokens.
    * @param _weiAmount Value in wei to be converted into tokens
    * @return Number of tokens that can be purchased with the specified _weiAmount
    */
    function _getTokenAmount(uint256 _weiAmount) internal view returns (uint256) {
        return _weiAmount.mul(rate).mul(bonusMultiplier).div(1000);
    }

    // // Roles
    // function addRole(address _operator, string _role) onlyOwner public {
    //     roles[_role].add(_operator);
    //     emit RoleAdded(_operator, _role);
    // }

    // function removeRole(address _operator, string _role) onlyOwner public {
    //     roles[_role].remove(_operator);
    //     emit RoleRemoved(_operator, _role);
    // }

//     /**
//     * @dev Closes the period in which the crowdsale is open.
//     */
//     function closeCrowdsale(bool closed_) public onlyOwner {
//         closed = closed_;
//     }
    // // Token Purchase
    // // =========================
    // function () external payable {
    //     require(msg.value >= minimumInvest);  // beneficiary values should be more than minium invest
    //     // require(totalTokenAvailableInThisStage > );
        
    //     // uint256 tokensGet = msg.value.mul(rate) + bonusMultiplier;

    //     // if ((stage == CrowdsaleStage.PrivateSale)) {
    //     //     msg.sender.transfer(msg.value);
    //     //     return;
    //     // }

    //     buyTokens(msg.sender);

    //     // if (stage == CrowdsaleStage.PreICO) {
    //     //     totalWeiRaisedDuringPreICO = totalWeiRaisedDuringPreICO.add(msg.value);
    //     // }
    // }
    // // Finish: Mint Extra Tokens as needed before finalizing the Crowdsale.
    // // ====================================================================

    // function finish(address _team, address _advisor) public onlyOwner {

    //     require(!closed);
    //     uint256 alreadyMinted = token.totalSupply();
    //     require(alreadyMinted < maxTokens);

    //     if (stage == CrowdsaleStage.PrivateSale){
    //         uint256 unsoldTokens = totalTokenAvailableInThisStage - alreadyMinted;
    //         if (unsoldTokens > 0) {
    //             // mint to match cap for this stage
    //         }
    //     }
        
    //     // token.mint(_teamFund,tokensForTeam);
    //     // token.mint(_ecosystemFund,tokensForEcosystem);
    //     // token.mint(_bountyFund,tokensForBounty);
    //     // finalize();
    // }
    // ===============================
}




