const DaiToken = artifacts.require("DaiToken");

module.exports = function(deployer, network, accounts) {
  const tokenOwner = accounts[0];
  const platformOwner = accounts[1];
  let DaiTokenInstance;

  return deployer.then(() => {
    return deployer.deploy(DaiToken, {from: tokenOwner});
  })
  .then((inst) => {
    DaiTokenInstance = inst;
    return DaiTokenInstance.mint(
      platformOwner,
      "1000000000000000000000000"
    )
  }).then(() => {
    return DaiTokenInstance.renounceMinter();
  })
};
