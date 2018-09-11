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
    this.rate = 40000;
    this.wallet = wallet;
    this.tokenAddress = "";
    this.openingTime = 1536710400; // Wednesday, September 12, 2018 12:00:00 AM
    this.closingTime = 1538265600; // Sunday, September 30, 2018 12:00:00 AM
    this.newOpeningTime = 1538697600; // Friday, October 5, 2018 12:00:00 AM
    this.newClosingTime = 1540857600; // Tuesday, October 30, 2018 12:00:00 AM
    this.stageValue = 0;
    this.stagesEnum = { "PrivateSale":0, "PreSale":1, "PublicSale":2};
    //Deploy crowdsale
    this.crowdsale = await TrainDanyCrowdsale.new(
      this.stageValue,
      this.openingTime, 
      this.closingTime, 
      this.rate, 
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
    it('Tracks the rate', async function(){
      const rate = await this.crowdsale.rate.call();
      rate.should.be.bignumber.equal(this.rate);
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
      await this.crowdsale.changeTime(this.newClosingTime);
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
    it('should set the stage to private sale', async function () {
      const stage = await this.crowdsale.stage.call();
      assert.equal(stage.toNumber(), 0, 'The stage couldn\'t be set to PrivateSale');
    });

    it('should change the stage to public sale sale', async function () {
      await this.crowdsale.setCrowdsale(2, this.openingTime, this.closingTime);
      const stage = await this.crowdsale.stage.call();
      assert.equal(stage.toNumber(), 2, 'The stage couldn\'t be set to PrivateSale');
    });
  });

  // describe('KYC', function(){
  //   // test for adding into whitelist
  //   it('Should add the address to whitelist', async function(){
  //     const whitelisted = await this.crowdsale.addAddressToWhitelist(whiteListedAddress);
  //     whitelisted.should.equal(true);

  //   });
  //   // test for removing from whitelist

  //   // test for roles
  // });

});

// contract('TrainDanyCrowdsale', function(accounts) {
//   describe('Crowdsale', function(){
//     // test for crowdsale
//   });

//   describe('Timed Crowdsale', function() {
//     // test for timed crowdsale

//     // test crowdsale stages

//     // test crowdsale closing time

//     // test crowdsale 
//   });

//   it('should deploy the token and store the address', function(done){
//     TrainDanyCrowdsale.deployed().then(async function(instance) {
//       const token = await instance.token.call();
//       assert(token, 'Token address couldn\'t be stored');
//       done();
//     });
//   });

//   // it('should be freezed 500 000 000 TDY token for advisors for 6 months', function(done){
//   //   TrainDanyCrowdsale.deployed().then(async function (instance) {
//   //     // transfer token to advisors address

//   //     // and check for freezeing
//   //     await instance.sendTransaction(advisor);

//   //   });
//   // });

//   // it('should be freezed 312 500 000 of token for team for 1 year', function(done){
//   //   TrainDanyCrowdsale.deployed().then(async function (instance) {
//   //     await instance.
//   //   });
//   // });

//   // it('should be freezed 312 500 000 of token for team for 2 year', function(done){
//   //   TrainDanyCrowdsale.deployed().then(async function (instance) {
//   //     await instance.
//   //   });
//   // });

//   it('should set stage to Private Sale', function(done){
//     TrainDanyCrowdsale.deployed().then(async function(instance) {
//       await instance.setCrowdsaleStage(0);
//       const stage = await instance.stage.call();
//       assert.equal(stage.toNumber(), 0, 'The stage couldn\'t be set to Private Sale');
//       done();
//     });
//   });

//   it('one ETH should buy 40000 TDY Tokens', function(done){
//     TrainDanyCrowdsale.deployed().then(async function(instance) {
//       const data = await instance.sendTransaction({ from: accounts[7], value: web3.toWei(1, "ether")});
//       const tokenAddress = await instance.token.call();
//       const trainDanyToken = TrainDanyToken.at(tokenAddress);
//       const tokenAmount = await trainDanyToken.balanceOf(accounts[7]);
//       assert.equal(tokenAmount.toNumber(), 5000000000000000000, 'The sender didn\'t receive the tokens as per rate');
//       done();
//     });
//   });

//   it('should transfer the ETH to wallet immediately in Pre ICO', function(done){
//     HashnodeCrowdsale.deployed().then(async function(instance) {
//       let balanceOfBeneficiary = await web3.eth.getBalance(accounts[9]);
//       balanceOfBeneficiary = Number(balanceOfBeneficiary.toString(10));

//       await instance.sendTransaction({ from: accounts[1], value: web3.toWei(2, "ether")});

//       let newBalanceOfBeneficiary = await web3.eth.getBalance(accounts[9]);
//       newBalanceOfBeneficiary = Number(newBalanceOfBeneficiary.toString(10));

//       assert.equal(newBalanceOfBeneficiary, balanceOfBeneficiary + 2000000000000000000, 'ETH couldn\'t be transferred to the beneficiary');
//       done();
//     });
//   });

//   it('should set variable `totalWeiRaisedDuringPreICO` correctly', function(done){
//     HashnodeCrowdsale.deployed().then(async function(instance) {
//       var amount = await instance.totalWeiRaisedDuringPreICO.call();
//       assert.equal(amount.toNumber(), web3.toWei(3, "ether"), 'Total ETH raised in PreICO was not calculated correctly');
//       done();
//     });
//   });

//   it('should set stage to ICO', function(done){
//     HashnodeCrowdsale.deployed().then(async function(instance) {
//       await instance.setCrowdsaleStage(1);
//       const stage = await instance.stage.call();
//       assert.equal(stage.toNumber(), 1, 'The stage couldn\'t be set to ICO');
//       done();
//     });
//   });

//   it('one ETH should buy 2 Hashnode Tokens in ICO', function(done){
//     HashnodeCrowdsale.deployed().then(async function(instance) {
//       const data = await instance.sendTransaction({ from: accounts[2], value: web3.toWei(1.5, "ether")});
//       const tokenAddress = await instance.token.call();
//       const hashnodeToken = HashnodeToken.at(tokenAddress);
//       const tokenAmount = await hashnodeToken.balanceOf(accounts[2]);
//       assert.equal(tokenAmount.toNumber(), 3000000000000000000, 'The sender didn\'t receive the tokens as per ICO rate');
//       done();
//     });
//   });

//   it('should transfer the raised ETH to RefundVault during ICO', function(done){
//     HashnodeCrowdsale.deployed().then(async function(instance) {
//       var vaultAddress = await instance.vault.call();

//       let balance = await web3.eth.getBalance(vaultAddress);

//       assert.equal(balance.toNumber(), 1500000000000000000, 'ETH couldn\'t be transferred to the vault');
//       done();
//     });
//   });

//   it('Vault balance should be added to our wallet once ICO is over', function(done){
//     HashnodeCrowdsale.deployed().then(async function(instance) {
//       let balanceOfBeneficiary = await web3.eth.getBalance(accounts[9]);
//       balanceOfBeneficiary = balanceOfBeneficiary.toNumber();

//       var vaultAddress = await instance.vault.call();
//       let vaultBalance = await web3.eth.getBalance(vaultAddress);

//       await instance.finish(accounts[0], accounts[1], accounts[2]);

//       let newBalanceOfBeneficiary = await web3.eth.getBalance(accounts[9]);
//       newBalanceOfBeneficiary = newBalanceOfBeneficiary.toNumber();

//       assert.equal(newBalanceOfBeneficiary, balanceOfBeneficiary + vaultBalance.toNumber(), 'Vault balance couldn\'t be sent to the wallet');
//       done();
//     });
//   });
// });