const hre = require("hardhat");

async function main() {

  //deploy token
  const Token = await hre.ethers.getContractFactory("ChainGrowBabiesToken");
  const token = await Token.deploy();
  await token.deployed();
  console.log("Token deployed to:", token.address);

  //deploy NFT
  const linkAddress = '0x326C977E6efc84E512bB9C30f76E30c160eD06FB';
  const oracleAddress = '0xB9756312523826A566e222a34793E414A81c88E1';
  const NFT = await hre.ethers.getContractFactory("ChainGrowBabiesNFT");
  const nft = await NFT.deploy(linkAddress, oracleAddress, token.address);
  await nft.deployed();
  console.log("NFT deployed to:", nft.address);

  //fund NFT
  const link = await hre.ethers.getContractAt("LinkTokenInterface", linkAddress);
  const nftLinkBalanceBefore = await link.balanceOf(nft.address);
  console.log('NFT contract balance before funding is: ' + nftLinkBalanceBefore / 1e18);
  
  //impersonate LINK whale address
  const accountToInpersonate = '0xE4dDb4233513498b5aa79B98bEA473b01b101a67';
  await hre.network.provider.request({
    method: "hardhat_impersonateAccount",
    params: [accountToInpersonate],
  });
  const signer = await ethers.getSigner(accountToInpersonate);
  
  const whaleLinkBalance = await link.balanceOf(accountToInpersonate);
  console.log('Whale LINK balance is: ' + whaleLinkBalance / 1e18);
  console.log("transfering LINK to", nft.address);

  //
  await link.connect(signer).transfer(nft.address, whaleLinkBalance);
  const accountBalance = await link.balanceOf(nft.address);

  console.log("transfer complete");

  const nftLinkBalanceAfter = await link.balanceOf(nft.address);
  console.log("NFT contract LINK balance after funding is: ", nftLinkBalanceAfter / 1e18);

  const whaleBalanceAfter = await link.balanceOf(accountToInpersonate);
  console.log("Whale LINK balance after funding is: ", whaleBalanceAfter / 1e18);
  
  //mint 3 NFTs
  //create instance of NFT contract
  const accounts = await hre.ethers.getSigners();

  for (let i = 0; i < 3; i++) {
    await nft.mint();
    console.log(`Nft #${i} minted`)
    console.log('\n')
  }

  for (let i = 1; i < 4; i++) {
    const tokenURI = await nft.getTokenURI(i);
    console.log(tokenURI + '\n\n');
    console.log('\n')
  }

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
