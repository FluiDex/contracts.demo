// We require the Hardhat Runtime Environment explicitly here. This is optional 
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hre = require("hardhat");

async function main() {
  // Hardhat always runs the compile task when running scripts with its command
  // line interface.
  //
  // If this script is run directly using `node` you may want to call compile 
  // manually to make sure everything is compiled
  // await hre.run('compile');

  // We get the contract to deploy
  const verifierFactory = await ethers.getContractFactory("KeyedVerifier");
  verifier = await verifierFactory.deploy();
  await verifier.deployed();
  console.log("Verifier deployed to:", verifier.address);

  const fluidexFactory = await ethers.getContractFactory("FluiDexDemo");
  let genesisRoot = process.env.GENESIS_ROOT;
  console.log("genesisRoot:", genesisRoot);
  fluidex = await fluidexFactory.deploy(genesisRoot, verifier.address);
  await fluidex.deployed();
  // await fluidex.initialize();
  console.log("FluiDex deployed to:", fluidex.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
