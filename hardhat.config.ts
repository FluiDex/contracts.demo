import { HardhatUserConfig } from "hardhat/config";
import "@nomiclabs/hardhat-etherscan";
import "@nomiclabs/hardhat-waffle";

import { infuraApiKey, walletPrivateKey, etherscanApiKey } from './secrets.json';

const config: HardhatUserConfig = {
  defaultNetwork: "geth",
  networks: {
    geth: {
      url: "http://localhost:8545",
      gas: 3000000,
      gasPrice: 10,
    },
    goerli: {
      url: `https://goerli.infura.io/v3/${infuraApiKey}`,
      accounts: [walletPrivateKey],
      gas: 30000000,
    }
  },
  etherscan: {
    apiKey: etherscanApiKey
  },
  solidity: {
    version: "0.8.4",
    settings: {
      optimizer: {
        enabled: true,
        runs: 1000,
      }
    }
  }
};

export default config;
