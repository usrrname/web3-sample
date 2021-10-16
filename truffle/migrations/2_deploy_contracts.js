const DynamicToken = artifacts.require("DynamicToken");

module.exports = function (deployer) {
  deployer.deploy(DynamicToken);
};
