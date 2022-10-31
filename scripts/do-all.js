const { ethers } = require("hardhat");
const hre = require("hardhat");

async function main() {
  //get signers
  const [owner, addr1, addr2] = await ethers.getSigners();
  const mintPrice = ethers.utils.parseEther("1.0");
  console.log(mintPrice);
  console.log(owner.address);

  //deploy token
  const Token = await hre.ethers.getContractFactory("ChainGrowBabiesToken");
  const token = await Token.deploy();
  await token.deployed();
  console.log("\nToken deployed to:", token.address);

  //send tokens from owner to user1 address
  token.connect(owner).transfer(addr1.address, mintPrice);
  console.log('\n1 ether of tokens transferred from owner to user1');

  //deploy NFT
  const linkAddress = '0x326C977E6efc84E512bB9C30f76E30c160eD06FB';
  const oracleAddress = '0xB9756312523826A566e222a34793E414A81c88E1';
  const NFT = await hre.ethers.getContractFactory("ChainGrowBabiesNFT");
  const nft = await NFT.deploy(linkAddress, oracleAddress, token.address);
  await nft.deployed();
  console.log("\nNFT deployed to:", nft.address);

  //approve NFT contract to spent user1's tokens so that we can move babies around
  await token.connect(addr1).approve(nft.address, (mintPrice));
  const allowanceAmount = await token.allowance(addr1.address, nft.address);
  const allowanceAmountString = allowanceAmount.toString();
  console.log(`\nallowance amount is: ${allowanceAmountString}`);

  //impersonate LINK whale address and send LINK to NFT contract
  const link = await hre.ethers.getContractAt("LinkTokenInterface", linkAddress);
  
  const accountToInpersonate = '0xE4dDb4233513498b5aa79B98bEA473b01b101a67';
  await hre.network.provider.request({
    method: "hardhat_impersonateAccount",
    params: [accountToInpersonate],
  });
  
  const linkWhale = await ethers.getSigner(accountToInpersonate);
  const linkWhaleBalance = await link.balanceOf(linkWhale.address);
  await link.connect(linkWhale).transfer(nft.address, linkWhaleBalance);
  
  //mint 3 NFTs
  for (let i = 0; i < 3; i++) {
    await nft.connect(addr1).mint();
    console.log(`Nft #${i} minted`)
    console.log('\n')
  }

  //log tokenURI's
  for (let i = 1; i < 4; i++) {
    const tokenURI = await nft.tokenURI(i);
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
