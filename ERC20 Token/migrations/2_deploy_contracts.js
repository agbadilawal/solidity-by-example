const ERC20Token = artifacts.require("ERC20Token.sol");

module.exports = function (deployer) {
  deployer.deploy(ERC20Token, "Lawal Token", "LTK", 18, web3.utils.toWei("1"));
};
