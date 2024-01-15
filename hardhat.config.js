// require("@matterlabs/hardhat-zksync-solc");
require('dotenv').config();

// /** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  etherscan: {
    apiKey: process.env.ETHERSCAN_API_KEY,
  },
  networks: {
    seoplia: {
      url: `https://sepolia.infura.io/v3/${process.env.INFURA_API_KEY}`,
      accounts: [`0x${process.env.PRI_KEY}`],
    },
  },
  solidity: {
    version: "0.8.17",
    defaultNetwork:"sepolia",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },
};
