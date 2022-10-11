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
  const nftAddress = '0x48D662D1D10505f9bf25c993f30c40118A37E7a2';

  //get contract at
  const linkAddress = '0x326C977E6efc84E512bB9C30f76E30c160eD06FB';
  const link = await hre.ethers.getContractAt("LinkTokenInterface", linkAddress);

  //check NFT link balance (should be 0)
  //const nft = await hre.ethers.getContractAt("ChainGrowBabiesNFT", nftAddress);
  const nftLinkBalanceBefore = await link.balanceOf(nftAddress);
  console.log(nftLinkBalanceBefore.toString())

  //fund it
  
  
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
