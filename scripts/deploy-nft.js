// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hre = require("hardhat");

async function main() {
  // Hardhat always runs the compile task when running scripts with its command
  // line interface.
  //
  // If this script is run directly using `node` you may want to call compile
  // manually to make sure everything is compiled
  // await hre.run('compile');
  const linkAddress = '0x326C977E6efc84E512bB9C30f76E30c160eD06FB'
  const oracleAddress = '0xB9756312523826A566e222a34793E414A81c88E1'
  const tokenAddress = '0xc9D18D86f1c101Dc87A09e683875004A02a67607';

  // We get the contract to deploy
  const NFT = await hre.ethers.getContractFactory("ChainGrowBabiesNFT");
  const nft = await NFT.deploy(linkAddress, oracleAddress, tokenAddress);



  await nft.deployed();

  console.log("NFT deployed to:", nft.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
