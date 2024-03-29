// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hre = require("hardhat");
const web3 = require("web3");

async function main() {
  // Hardhat always runs the compile task when running scripts with its command
  // line interface.
  //
  // If this script is run directly using `node` you may want to call compile
  // manually to make sure everything is compiled
  // await hre.run('compile');

  // deploy loot
  // const Loot = await hre.ethers.getContractFactory("Loot");
  // const loot = await Loot.deploy();

  // await loot.deployed();

  // console.log("Loot deployed to:", loot.address);

  // deploy loot components
  // const LootComp = await hre.ethers.getContractFactory("LootComponents");
  // const lootcomp = await LootComp.deploy();

  // await lootcomp.deployed();

  // console.log("Loot Component deployed to:", lootcomp.address);


  // deploy lootbatles
  // const LootBattles = await hre.ethers.getContractFactory("LootBattles");
  // const lootbattles = await LootBattles.deploy();

  // await lootbattles.deployed();

  // console.log("LootBattles deployed to:", lootbattles.address)

  // deploy xxxLoot
try {
  const msgNFT = await hre.ethers.getContractFactory("BloomSquad");
  const msgNFTDeployer = await msgNFT.deploy();

  await msgNFTDeployer.deployed();

  console.log("msgme deployed to:", msgNFTDeployer.address)
} catch (error)
{
  console.log(error)
}
  
  // console.log(await web3.eth.getStorageAt('0x2Ab87b220843F6C8883db28fCc4F40Aa1e550d92', 0));
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
