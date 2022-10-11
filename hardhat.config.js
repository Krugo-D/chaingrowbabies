require("@nomiclabs/hardhat-waffle");
require("dotenv").config();

// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

//const mnemonic = process.env.MNEMONIC;
//const alchemyUrl = process.env.ALCHEMY_URL;

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  solidity: {
    compilers: [
      {
          version: "0.8.9"
      }
    ]
  },
  defaultNetwork: "hardhat",
  networks: {
    hardhat: {
      forking: {
        url: 'https://rpc.goerli.mudit.blog/'
      },
    }
  }
};

