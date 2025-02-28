import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
require("dotenv").config();

const { ACCOUNT_PRIVATE_KEY, ETHERSCAN_API_KEY, HOLESKY_API_KEY } = process.env;

const config: HardhatUserConfig = {
  solidity: "0.8.28",
  
  networks: {
    holesky: {
      url: HOLESKY_API_KEY,
      accounts: [`0x${ACCOUNT_PRIVATE_KEY}`]
    }
  },
  etherscan: {
    apiKey: ETHERSCAN_API_KEY
  },
  sourcify: {
    enabled: false,
  }
};

export default config;
