const TrainDanyToken = artifacts.require("./TrainDanyToken.sol");
const BigNumber = web3.BigNumber;

require("chai")
  .use(require("chai-bignumber")(BigNumber))
  .should();

contract('TrainDanyToken', accounts => {
  var creatorAddress = accounts[0];
  var recipientAddress = accounts[1];
  var delegatedAddress = accounts[2];
  const _name = "TrainDany";
  const _symbol = "TDY";
  const _decimals = 8;
  const _totalSupply = 6250000000 * (10 ** _decimals);
  const _version = "V1.0";

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
    it("Should be 625000000000000000 Total Supply of tokens", async function() {
      const cap = await this.token.totalSupply();
      cap.should.be.bignumber.equal(_totalSupply);
    });
    // test owner balance
    it("Should have 625000000000000000 TDY Token in Owners balance", async function() {
      const balance = await this.token.balanceOf(creatorAddress);
      balance.should.be.bignumber.equal(625000000000000000);
    });
    // test version number
    it("Should be V1.0 in versioning number", async function(){
      const version = await this.token.version();
      version.should.equal(_version);
    });
  });
});