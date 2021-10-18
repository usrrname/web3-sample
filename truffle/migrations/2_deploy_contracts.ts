type Network = "development" | "kovan" | "mainnet";
import Truffle from "@typechain/truffle-v5";
import Web3 from "@typechain/truffle-v5";

module.exports = (artifacts: Truffle, web3: Web3) => {
  return async (deployer: any, network: Network, accounts: string[]) => {
    const DynamicToken = require("../contracts/DynamicToken.sol");

    await deployer.deploy(DynamicToken);

    const dynamicToken = await DynamicToken.deployed();
    console.log(
      `DynamicToken contract deployed at ${dynamicToken.address} in network: ${network}.`
    );
  };
};
