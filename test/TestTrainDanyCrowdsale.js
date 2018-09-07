const TrainDanyCrowdsale = artifacts.require("./TrainDanyCrowdsale.sol");
const BigNumber = web3.BigNumber;

require("chai")
  .use(require("chai-bignumber")(BigNumber))
  .should();

// contract('TrainDanyCrowdsale', accounts => {
//     const _name = "Train Dany";
//     const _symbol = "TDY";
//     const _decimals = 8;
//     const _cap = 6250000000;
  
//     beforeEach(async function(){
//       this.token = await TrainDanyCrowdsale.new();
//     });
// });