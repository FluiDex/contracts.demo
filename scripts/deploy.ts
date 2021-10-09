import { run, ethers } from "hardhat";
import * as hre from "hardhat";
import { default as tokens} from "../tokens";

async function main() {
  await run('compile');

  const verifierFactory = await ethers.getContractFactory("KeyedVerifier");
  const verifier = await verifierFactory.deploy();
  await verifier.deployed();
  console.log("Verifier deployed to:", verifier.address);

  const fluidexFactory = await ethers.getContractFactory("FluiDexDemo");
  const genesisRoot = process.env.GENESIS_ROOT;
  console.log("genesisRoot:", genesisRoot);
  const fluiDex = await fluidexFactory.deploy(genesisRoot, verifier.address);
  await fluiDex.deployed();
  console.log("FluiDex deployed to:", fluiDex.address);
  const addToken = fluiDex.functions.addToken;
  for (const {name, address} of Array.from(tokens)) {
    await addToken(address);
    console.log(`add ${name} token at`, address);
  }

  const fluiDexDelegateFactory = await ethers.getContractFactory("FluiDexDelegate");
  const fluiDexDelegate = await fluiDexDelegateFactory.deploy(fluiDex.address);
  await fluiDexDelegate.deployed();
  console.log("FluiDexDelegate deployed to:", fluiDexDelegate.address);

  // skip verify on localhost
  if (hre.network.name !== "localhost") {
    await run('verify', {
      address: verifier.address,
      contract: "contracts/Verifier.sol:KeyedVerifier",
    });
    await run('verify', {
      address: fluiDex.address,
      contract: "contracts/FluiDex.sol:FluiDexDemo",
      constructorArgsParams: [genesisRoot, verifier.address],
    });
    await run('verify', {
      address: fluiDexDelegate.address,
      contract: "contracts/FluiDexDelegate.sol:FluiDexDelegate",
      constructorArgsParams: [fluiDex.address],
    });
  }
}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
