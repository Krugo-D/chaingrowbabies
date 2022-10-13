const hre = require("hardhat");

async function main() {

  //deploy token
  const Token = await hre.ethers.getContractFactory("ChainGrowBabiesToken");
  const token = await Token.deploy();
  await token.deployed();
  console.log("Token deployed to:", token.address + '\n');

  const linkAddress = '0x326C977E6efc84E512bB9C30f76E30c160eD06FB'
  const oracleAddress = '0xB9756312523826A566e222a34793E414A81c88E1'

  // deploy NFT
  const NFT = await hre.ethers.getContractFactory("ChainGrowBabiesNFT");
  const nft = await NFT.deploy(linkAddress, oracleAddress, token.address);

  await nft.deployed();

  console.log("NFT deployed to:", nft.address + '\n');


}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
