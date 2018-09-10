// solium-disable linebreak-style
pragma solidity ^0.4.24;

import "./../node_modules/openzeppelin-solidity/contracts/crowdsale/validation/TimedCrowdsale.sol";
import "./../node_modules/openzeppelin-solidity/contracts/crowdsale/Crowdsale.sol";
import "./../node_modules/openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "./../node_modules/openzeppelin-solidity/contracts/access/Whitelist.sol";
import "./../node_modules/openzeppelin-solidity/contracts/crowdsale/distribution/FinalizableCrowdsale.sol";
import "./TrainDanyToken.sol";

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

    // TODO: Token should be freezed 


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
    constructor(uint _stageValue, uint256 _startTime, uint256 _endTime, uint256 _rate, address _wallet, TrainDanyToken _trainDanyToken) 
        Crowdsale(_rate, _wallet, _trainDanyToken) 
        public {
        setCrowdsaleStage(_stageValue); // set crrowdsale
    }
    // =============

    // Token Deployment
    // =================
    function createTokenContract() internal returns (MintableToken) {
        return new TrainDanyToken();                // Deploys the ERC20 token. Automatically called when crowdsale contract is deployed
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
            // TODO: Freeze automatic
            
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
