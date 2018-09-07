
// File: contracts\TrainDanyCrowdsale.sol

// // solium-disable linebreak-style
// pragma solidity ^0.4.24;

// import "./../node_modules/openzeppelin-solidity/contracts/crowdsale/validation/TimedCrowdsale.sol";
// import "./../node_modules/openzeppelin-solidity/contracts/crowdsale/Crowdsale.sol";
// import "./../node_modules/openzeppelin-solidity/contracts/ownership/Ownable.sol";
// import "./../node_modules/openzeppelin-solidity/contracts/access/Whitelist.sol";
// import "./TrainDanyToken.sol";

// contract TrainDanyCrowdsale is Crowdsale, Ownable {
//     // TODO: Whitelisted applying on Stages
//     // TODO: Change opening date and closing date
//     // TODO: calculate Bonus
//     // TODO: Share holders

//     // TODO: Time crowdsale depending on sales stage

//     // ICO Stages Initializations ======================================================
//     enum CrowdsaleStage { Privatesale, Presale, Publicsale }        // All 3 Sale Stages
//     CrowdsaleStage private stage;                                   // the sale stages
//     uint256 private startTime;                                      // Unix Epoch Time 1536105600 @ September 5, 2018 12:00:00 AM 
//     uint256 private endTime;                                        // Unix Epoch Time  1537833600 @ September 25, 2018 12:00:00 AM
//     TrainDanyToken private trainDanyToken;                          // The actual token contract for the TDY
//     ERC20 private token;                                            // The ERC20 TDY Token Contract  
//     address private wallet;                                         // Address where funds are collected "0x1406335646bf1fca47c9d08925f59c3f46b50276"
//     // How many token units a buyer gets per wei.
//     // The rate is the conversion between wei and the smallest and indivisible token unit.
//     // So, if you are using a rate of 1 with a DetailedERC20 token with 3 decimals called TOK
//     // 1 wei will give you 1 unit, or 0.001 TOK.
//     uint256 public rate;  // 25000000000000 wei will provide 1 TDY token
    
//     constructor(CrowdsaleStage _stage, uint256 _rate, address _wallet, ERC20 _token) public Crowdsale(_rate, _wallet, _token) {
//         stage = _stage;
//     }

//     bool private privatesale = false;
//     bool private presale = false;
//     bool private publicsale = false;                                      
//     uint private bonus; // bonus multiplier for the sale
//     uint private minimumInvest; // Minimum invest cap for the investors

    

//     function initializeCrowdsale(uint _stageValue, uint256 _startTime, uint256 _endTime) public onlyOwner {
//         // check if current crowdsale is finished
//         if (_stageValue == uint(CrowdsaleStage.Privatesale) && !presale && !publicsale) {
//             startTime = _startTime;
//             endTime = _endTime;
//             stage = CrowdsaleStage.Privatesale;
//             setCurrentStage(stage, startTime, endTime);
//         } else if (_stageValue == uint(CrowdsaleStage.Presale) && !privatesale && !publicsale) {
//             startTime = _startTime;
//             endTime = _endTime;
//             stage = CrowdsaleStage.Presale;
//             setCurrentStage(stage, startTime, endTime);
//         } else if (_stageValue == uint(CrowdsaleStage.Publicsale) && !privatesale && !presale) {
//             startTime = _startTime;
//             endTime = _endTime;
//             stage = CrowdsaleStage.Publicsale;
//             setCurrentStage(stage, startTime, endTime);
//         }
//     }
 
//     function getCurrentSaleStage() public view returns(string) {
//         // TODO: add also time line
//         if (stage == CrowdsaleStage.Privatesale){
//             return "Private Sale";
//         } else if (stage == CrowdsaleStage.Presale) {
//             return "Pre sale";
//         } else if (stage == CrowdsaleStage.Publicsale) {
//             return "Public sale";
//         } else if (stage == Null){
//             return "No Sale has been started";
//         }
//     }

//     function getCurrentBonus () public view returns(uint) {
//         return bonus;
//     }

//     function setCurrentStage(Crowdsale _stage, uint256 _startTime, uint256 _endTime) public onlyOwner {
        
//         if (_stage == CrowdsaleStage.publicsale){
//             // set bonus multiplier
//             require ( now >= startime && now <= endtime);
//             if (startTime <= startTime + 1 weeks) {
//                 bonus = 2000;
//             } else if (startTime >= startTime + 2 weeks) {
//                 bonus = 1000;
//             } else if (startTime <= startTime + 3 weeks) {
//                 bonus = 500;
//             } else if (startTime <= startTime + 4 weeks) {
//                 bonus = 0;
//             }
//             // set minimum invest
//             minimumInvest = 0.1 ether;
//             // set time

//             // set flag
//             publicsale = true;
//             privatesale = false;
//             presale = false;

//         } else if (stage == CrowdsaleStage.presale) {
//             bonus = 3000;
//             minimumInvest = 0.1 ether;
//             publicsale = false;
//             privatesale = false;
//             presale = true;
//         } else if (stage == CrowdsaleStage.privatesale) {
//             bonus = 5000;
//             minimumInvest = 250 ether;
//             publicsale = false;
//             privatesale = true;
//             presale = false;
//         }

//     }

//     // Auto finalize crowdsale

//     // 
//     // uint32[] public BONUS_TIMES;
//     // uint32[] public BONUS_TIMES_VALUES;
//     // uint32[] public BONUS_AMOUNTS;
//     // uint32[] public BONUS_AMOUNTS_VALUES;
//     // uint public constant BONUS_COEFF = 1000; // Values should be 10x percents, values from 0 to 1000
//     // ================ Initialize ================================
//     // ================ Stage Management Over =====================
//     // ================ Finalization ==============================
//     // Change Crowdsale Stage. Available Options: Privatesale, Presale, Publicsale
   



//     uint256 private _rate = 40000; // 1 ETH = 40000 TDY Token
//     address private _wallet; // = ; address of the beneficiary
//     ERC20 private _tokenContract; 

//     uint256 public minimalInvestmentInWei = 5 ether;
//     address public tokenAddress;
//     uint256 private tokenPrice;

//     TrainDanyToken public trainDanyToken;

//     event InitialDateReset(uint256 startTime, uint256 endTime);
//     event InitialRateChange(uint256 rate, uint256 cap, uint256 minimalInvestment);

//     // uint256 _rate, address _wallet, ERC20 _token


//     // Constructor
//     constructor(uint256 _startTime, uint256 _endTime) 
//         Crowdsale(_rate, _wallet, _token) TimedCrowdsale(startTime, endTime) public {

//     }
//     // bonus multiplie according to time (weeks)

//     // time reset machanism
//     /**
//     * @dev Reset start and end date/time for this Presale.
//     * @param _startTime change presale start time
//     * @param _endTime change presale end period
//     */
//     function setSaleDates(uint256 _startTime, uint256 _endTime) public onlyOwner returns (bool) { 
//         require(startTime > block.timestamp);
//         require(_startTime >= now);
//         require(_endTime >= _startTime);

//         startTime = _startTime;
//         endTime = _endTime;

//         InitialDateReset(startTime, endTime);
//         return true;
//     }

//     /**
//     * @dev Sets the token conversion rate
//     * @param _rateInWei - Price of 1 Binkd token in Wei. 
//     * @param _capInWei - Cap of the Presale in Wei. 
//     * @param _minimalInvestmentInWei - Minimal investment in Wei. 
//     */
//     function setRate(uint256 _rateInWei, uint256 _capInWei, uint256 _minimalInvestmentInWei) public onlyOwner returns (bool) { 
//         require(startTime >= block.timestamp); // can't update anymore if sale already started
//         require(_rateInWei > 0);
//         require(_capInWei > 0);
//         require(_minimalInvestmentInWei > 0);

//         rate = _rateInWei;
//         cap = _capInWei;
//         minimalInvestmentInWei = _minimalInvestmentInWei;

//         InitialRateChange(rate, cap, minimalInvestmentInWei);
//         return true;
//     }

//     // set the token owner to contract owner
//     function reTransferTokenOwnership() onlyOwner public { 
//         TrainDanyToken.transferOwnership(owner);
//     }
// }
