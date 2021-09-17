const hre = require("hardhat");

function sleep(ms) {
    return new Promise((resolve) => setTimeout(resolve, ms));
}

async function main() {
  // We get the contract to deploy
  const TickerFactory = await ethers.getContractFactory("Ticker");
  ticker = await TickerFactory.deploy();
  await ticker.deployed();
  console.log("ticker deployed to:", ticker.address);

  while (true) {
      try {
        await sleep(1000);
        console.log("tick tock", await ticker.tick());
      } catch (e) {
        console.log("error", e);
      }
  }
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
