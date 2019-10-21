const TradeContract = artifacts.require("Trade");

module.exports = function(deployer, network, accounts) {
  const platformOwner = accounts[1];
  let DaiTokenInstance;

  return deployer.then(() => {
    return deployer.deploy(TradeContract, {from: platformOwner});
  });
}
