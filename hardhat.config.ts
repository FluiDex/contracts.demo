import { HardhatUserConfig } from "hardhat/config";
import "@nomiclabs/hardhat-etherscan";
import "@nomiclabs/hardhat-waffle";

import { infuraApiKey, walletPrivateKey, etherscanApiKey } from './secrets.json';

const config: HardhatUserConfig = {
  defaultNetwork: "hardhat",
  networks: {
    hardhat: {
      chainId: 1337,
      mining: {
        auto: false,
        interval: [3000, 6000]
      }
    },
    goerli: {
      url: `https://goerli.infura.io/v3/${infuraApiKey}`,
      accounts: [walletPrivateKey],
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