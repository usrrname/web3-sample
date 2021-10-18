import Web3 from "web3";
import DynamicToken from "../../truffle/build/contracts/DynamicToken.json";
let selectedAccount;

export const init = async () => {
  // checks if metamask is installed
  let provider = (window as any).ethereum;
  if (typeof provider !== null) {
    // gets access to users' accounts
    provider
      .request({ method: "eth_requestAccounts" })
      .then((accounts: any) => {
        selectedAccount = accounts[0];
        console.log(`Selected account:  ${selectedAccount}`);
      })
      .catch((err: Error) => {
        console.error(err);
      });
  } else if ((window as any).web3) {
    provider = (window as any).web3.currentProvider;
  } else {
    console.info("no account connected");
  }
  (window as any).ethereum.on("accountsChanged", (accounts: any) => {
    selectedAccount = accounts[0];
    console.log(`Selected account changed to:  ${selectedAccount}`);
  });

  const web3 = new Web3(provider);
  const networkId = await web3.eth.net.getId();
  const nftContract = new web3.eth.Contract(
    DynamicToken.abi,
    DynamicToken.networks[5777]
  );
};
