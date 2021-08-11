# contracts.demo

Contracts for FluiDex demo, using hardhat local node for now.

```
yarn install

// in one terminal
npx hardhat node

// set GENESIS_ROOT env
export GENESIS_ROOT=A_UINT256_NUMBER

// in another terminal
npx hardhat run scripts/deploy.js --network localhost
```
