const TradeContract = artifacts.require("Trade");
const DaiToken = artifacts.require("DaiToken");

module.exports = function(deployer, network, accounts) {
  const platformOwner = accounts[1];
  let DaiTokenInstance;

  return DaiToken.deployed().then((daiInstance)=>{
    DaiTokenInstance = daiInstance;
    return deployer.deploy(TradeContract, DaiTokenInstance.address, {from: platformOwner});
  }).then(()=>{
  });

}
