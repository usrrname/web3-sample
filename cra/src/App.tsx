import React, { useEffect } from "react";
import Web3 from "web3";
import logo from "./logo.svg";
import "./App.css";

function App() {
  const providerUrl = process.env.PROVIDER_URL || "http://localhost:9545";
  useEffect(() => {
    const web3 = new Web3(providerUrl);

    // checks if metamask is installed
    let provider = (window as any).ethereum;
    if (typeof provider !== null) {
      // gets access to users' accounts
      provider
        .request({ method: "eth_requestAccounts" })
        .then((accounts: any) => console.log(accounts))
        .catch((err: Error) => {
          console.error(err);
        });
    } else if ((window as any).web3) {
      provider = (window as any).web3.currentProvider;
    }
  }, [providerUrl]);

  return (
    <div className="App">
      <header className="App-header">
        <img src={logo} className="App-logo" alt="logo" />
        <p>
          Edit <code>src/App.tsx</code> and save to reload.
        </p>
        <a
          className="App-link"
          href="https://reactjs.org"
          target="_blank"
          rel="noopener noreferrer"
        >
          Learn React
        </a>
      </header>
    </div>
  );
}

export default App;
