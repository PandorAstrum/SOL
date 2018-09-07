var TDYToken = artifacts.require("./TDYToken.sol");

module.exports = async function(deployer) {
  await deployer.deploy(TDYToken);
  const deployedToken = await TDYToken.deployed();
  console.log(deployedToken.address);


  const duration = {
    seconds: function (val) { return val; },
    minutes: function (val) { return val * this.seconds(60); },
    hours: function (val) { return val * this.minutes(60); },
    days: function (val) { return val * this.hours(24); },
    weeks: function (val) { return val * this.days(7); },
    years: function (val) { return val * this.days(365); },
  };
};