const TrainDanyToken = artifacts.require("./TrainDanyToken.sol");
const BigNumber = web3.BigNumber;

require("chai")
  .use(require("chai-bignumber")(BigNumber))
  .should();

contract('TrainDanyToken', accounts => {

  // addresses for testing
  var creatorAddress = accounts[0];
  var recipientAddress = accounts[1];
  var delegatedAddress = accounts[2];
  var advisorsAddress = accounts[3];
  // general config for the token
  const _name = "TrainDany";
  const _symbol = "TDY";
  const _decimals = 8;
  const _version = "V1.0";
  const _salesCap = 4000000000;
  const _teamCap = 625000000;
  const _advisorCap = 500000000;
  const _reservedCap = 937500000;
  const _bonusCap = 187500000;
  const _totalSupply = (_salesCap + _teamCap + _advisorCap + _reservedCap + _bonusCap) * (10 ** _decimals);

  beforeEach(async function(){
    this.token = await TrainDanyToken.new();
  });

  describe("token attributes", function() {
    // test name
    it("Should be named TrainDany", async function() {
      const name = await this.token.name();
      name.should.equal(_name);
    });
    // test symbol
    it("Should be symbolize TDY", async function() {
      const symbol = await this.token.symbol();
      symbol.should.equal(_symbol);
    });
    // test decimals
    it("Should be 8 Decimals", async function() {
      const decimals = await this.token.decimals();
      decimals.should.be.bignumber.equal(_decimals);
    });
    //test token cap
    it("Should be 6 250 000 000 00000000 Total Supply of tokens", async function() {
      const cap = await this.token.totalSupply();
      cap.should.be.bignumber.equal(_totalSupply);
    });
    // test owner balance
    it("Should have 6 250 000 000 00000000 TDY Token in Owners balance", async function() {
      const balance = await this.token.balanceOf(creatorAddress);
      balance.should.be.bignumber.equal(625000000000000000);
    });
    // test total Sales Cap with bonus
    it("Should have 4 000 000 000 TDY Token Max cap for total sales", async function() {
      const salesCap = await this.token.salesCap.call();
      salesCap.should.be.bignumber.equal(_salesCap);
    });
    // test team cap
    it("Should have 625 000 000 TDY Token Max cap for Team", async function() {
      const teamCap = await this.token.teamCap.call();
      teamCap.should.be.bignumber.equal(_teamCap);
    });
    // test advisors cap
    it("Should have 500 000 000 TDY Token Max cap for Advisors", async function() {
      const advisorCap = await this.token.advisorCap.call();
      advisorCap.should.be.bignumber.equal(_advisorCap);
    });
    // test reserved cap
    it("Should have 937 500 000 TDY Token Max cap for Reserved", async function() {
      const reservedCap = await this.token.reservedCap.call();
      reservedCap.should.be.bignumber.equal(_reservedCap);
    });
    // test bonus cap
    it("Should have 187 500 000 TDY Token Max cap for bonus and bounty", async function() {
      const bonusCap = await this.token.bonusCap.call();
      bonusCap.should.be.bignumber.equal(_bonusCap);
    });
    // test version number
    it("Should be V1.0 in versioning number", async function(){
      const version = await this.token.version.call();
      // await this.token.version().should.equal(_version);
      version.should.equal(_version);
    });
    // pause state
    it("Should be Puased Token", async function(){
      const pause = await this.token.paused.call();
      pause.should.equal(false);
    });
    it("Should freeze the account for certain time", async function(){
      //transfer some tdy token 
      await this.token.transfer(advisorsAddress, 500000000);
      const freezeAc = await this.token.freezeAccount(advisorsAddress, true, 1538265600);
      // freezeAc.should.equal()
      
    });
  });
});