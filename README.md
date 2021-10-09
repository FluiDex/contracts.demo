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

## On testnet

### latest deploy:

- [KeyedVerifier on etherscan](https://goerli.etherscan.io/address/0xd91f2481680D8d95B16f950F1a82E76f7FBBD8ac#code)
- [FluiDexDemo on etherscan](https://goerli.etherscan.io/address/0x25EE4858bccAa755D8Ce3b870a31Dc82DbE1b11F#code)
- [FluiDexDelegate](https://goerli.etherscan.io/address/0xE436322a10695bB08d203e481A5433872966F896#code)

Get Test Token from our faucet.

### raw log

```
> $ npx hardhat run scripts/deploy.ts --network goerli
Compiling 19 files with 0.8.4
Compilation finished successfully
Nothing to compile
Verifier deployed to: 0xd91f2481680D8d95B16f950F1a82E76f7FBBD8ac
genesisRoot: 0x08d86d872ad1fc9c1b5e55369bdddb5188d4d2c0381a86a3f345fbac79b5fbf8
FluiDex deployed to: 0x25EE4858bccAa755D8Ce3b870a31Dc82DbE1b11F
add USDT token at 0x021030D7BA0B21633fE351e83C9b0b8035360329
add UNI token at 0xB412EcE47485D3CFbf65e1b95408D5679eF9c36d
add LINK token at 0x1bA66DB7A54738F5597FeCa2640fd2E717722230
add YFI token at 0xfb30fd66413c01547115C22B62Bde0fF3700DE1F
add MATIC token at 0x1185f0F4Ea8a713920852b6113F2C3eFe593899F
FluiDexDelegate deployed to: 0xE436322a10695bB08d203e481A5433872966F896
Nothing to compile
Compiling 1 file with 0.8.4
Successfully submitted source code for contract
contracts/Verifier.sol:KeyedVerifier at 0xd91f2481680D8d95B16f950F1a82E76f7FBBD8ac
for verification on Etherscan. Waiting for verification result...

Successfully verified contract KeyedVerifier on Etherscan.
https://goerli.etherscan.io/address/0xd91f2481680D8d95B16f950F1a82E76f7FBBD8ac#code
Compiling 19 files with 0.8.4
Compilation finished successfully
Compiling 1 file with 0.8.4
Successfully submitted source code for contract
contracts/FluiDex.sol:FluiDexDemo at 0x25EE4858bccAa755D8Ce3b870a31Dc82DbE1b11F
for verification on Etherscan. Waiting for verification result...

Successfully verified contract FluiDexDemo on Etherscan.
https://goerli.etherscan.io/address/0x25EE4858bccAa755D8Ce3b870a31Dc82DbE1b11F#code
Nothing to compile
Compiling 1 file with 0.8.4
Successfully submitted source code for contract
contracts/FluiDexDelegate.sol:FluiDexDelegate at 0xE436322a10695bB08d203e481A5433872966F896
for verification on Etherscan. Waiting for verification result...

Successfully verified contract FluiDexDelegate on Etherscan.
https://goerli.etherscan.io/address/0xE436322a10695bB08d203e481A5433872966F896#code
```

