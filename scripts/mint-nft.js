//mints an NFT and logs SVG image to console

const hre = require("hardhat");

async function main() {
	//create instance of NFT contract
  const nftAddress = '0x85fe2Dcd9fBcb3311f04aF11a0CF59c1beAa46bB';
  const nft = await hre.ethers.getContractAt("ChainGrowBabiesNFT", nftAddress);

	const accounts = await hre.ethers.getSigners();

	await nft.mint();
	const character = await nft.generateCharacter(1);
	console.log(character);

}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
