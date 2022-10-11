// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hre = require("hardhat");

async function main() {
  const nftAddress = '0x85fe2Dcd9fBcb3311f04aF11a0CF59c1beAa46bB';

  //get LINK token contract
  const linkAddress = '0x326C977E6efc84E512bB9C30f76E30c160eD06FB';
  const link = await hre.ethers.getContractAt("LinkTokenInterface", linkAddress);
  //const nft = await hre.ethers.getContractAt("ChainGrowBabiesNFT", nftAddress);
  const nftLinkBalanceBefore = await link.balanceOf(nftAddress);
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
  console.log("transfering LINK to", nftAddress);

  //
  await link.connect(signer).transfer(nftAddress, whaleLinkBalance);
  const accountBalance = await link.balanceOf(nftAddress);

  console.log("transfer complete");

  const whaleBalanceAfter = await link.balanceOf(accountToInpersonate)
  console.log("Whale LINK balance after funding is: ", whaleBalanceAfter / 1e18)

  const nftLinkBalanceAfter = await link.balanceOf(nftAddress);
  console.log("NFT contract LINK balance after funding is: ", nftLinkBalanceAfter / 1e18)

  
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
