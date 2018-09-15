import ether from "./helpers/ether";

const BigNumber = web3.BigNumber;

require("chai")
  .use(require("chai-as-promised"))
  .use(require("chai-bignumber")(BigNumber))
  .should();

const TrainDanyCrowdsale = artifacts.require("./TrainDanyCrowdsale.sol");
const TrainDanyToken = artifacts.require("./TrainDanyToken.sol");

contract('TrainDanyCrowdsale', function([_, wallet, investor1, investor2]){
  beforeEach(async function(){
    //token config
    this.name = "TrainDany";
    this.symbol = "TDY";
    this.decimals = 8;
    //Deploy token
    this.token = await TrainDanyToken.new();
    //Crowdsale Config
    this.wallet = wallet;
    this.openingTime = 1536969600;        // Wednesday, September 12, 2018 12:00:00 AM
    this.closingTime = 1538265600;        // Sunday, September 30, 2018 12:00:00 AM
    this.newOpeningTime = 1538697600;     // Friday, October 5, 2018 12:00:00 AM
    this.newClosingTime = 1540857600;     // Tuesday, October 30, 2018 12:00:00 AM
    this.stagesEnum = { "PrivateSale":0, "PreSale":1, "PublicSale":2};
    //Deploy crowdsale
    this.crowdsale = await TrainDanyCrowdsale.new(
      Date().now, 
      this.closingTime,
      this.wallet, 
      this.token.address
    );

    // transfer the ownership to crowdsale
    await this.token.transferOwnership(this.crowdsale.address);
  });

  describe('Crowdsale', function(){

    // tracks the token
    it('Tracks the token', async function(){
      const token = await this.crowdsale.token();
      token.should.equal(this.token.address);
    });
    // tracks the rate
    it('Tracks the rate, Should be 40000', async function(){
      const rate = await this.crowdsale.rate.call();
      rate.should.be.bignumber.equal(40000);
    });
    // tracts the wallet
    it('Tracks the wallet', async function () {
      const wallet = await this.crowdsale.wallet();
      wallet.should.equal(this.wallet);
    });
  });

  describe('Timed Crowdsale', function(){
    // Starting time
    it('Checks Starting time for sale', async function(){
      const startTime = await this.crowdsale.openingTime.call();
      startTime.should.be.bignumber.equal(this.openingTime);
    });
    // ending time
    it('Checks Ending time for sale', async function(){
      const endTime = await this.crowdsale.closingTime.call();
      endTime.should.be.bignumber.equal(this.closingTime);
    });
    // test time changes function
    it('Should change time to speified time', async function(){
      await this.crowdsale.changeDates(this.newOpeningTime, this.newClosingTime);
      const newClosingTime = await this.crowdsale.closingTime.call();
      newClosingTime.should.be.bignumber.equal(this.newClosingTime);
    });
  });

  describe('Accepting Payments', function(){
    it('Should accept payments', async function(){
      const value = ether(1);
      await this.crowdsale.sendTransaction({ value: value, from: investor1})
    });
  });

  describe('Crowdsale Stages', function() {
    // private sale
    it('should set the stage to private sale', async function () {
      const stage = await this.crowdsale.stage.call();
      assert.equal(stage.toNumber(), 0, 'The stage couldn\'t be set to PrivateSale');
    });
    // test buy with bonus multiplier
    it('should buy tokens for 250 ETH', async function(){
      //
    });
    // test the investor token 
    it('Investor should have tokens in their balance after purchase', async function(){
      //
    });
    // test the wallet to have the ether immediately
    it('The owner wallet should have the ether', async function(){
      // test the owners balance for ETHER
    });
    // pre sale
    it('should change the stage to Pre sale', async function () {
      await this.crowdsale.setCrowdsale(1, this.openingTime, this.closingTime);
      const stage = await this.crowdsale.stage.call();
      assert.equal(stage.toNumber(), 1, 'The stage couldn\'t be set to PreSale');
    });
    // public sale
    it('should change the stage to public sale', async function () {
      await this.crowdsale.setCrowdsale(2, this.openingTime, this.closingTime);
      const stage = await this.crowdsale.stage.call();
      assert.equal(stage.toNumber(), 2, 'The stage couldn\'t be set to Public saleSale');
    });
  });

});