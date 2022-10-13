//mints an NFT and logs SVG image to console

const hre = require("hardhat");

async function main() {
	//create instance of NFT contract
  const nftAddress = '0x502Dcaf7b2a3CE981F1a6c86cc4634b16c7a836f';
  const nft = await hre.ethers.getContractAt("ChainGrowBabiesNFT", nftAddress);

	const accounts = await hre.ethers.getSigners();

	await nft.mint();
	const character = await nft.generateCharacter(4);
	console.log(character);

}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
