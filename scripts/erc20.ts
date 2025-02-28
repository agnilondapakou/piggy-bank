import { ethers } from "hardhat";

async function main() {
  const [owner] = await ethers.getSigners();

  console.log(`Deploying contract with account: ${owner.address}`);

  // Deploy Tokens
  const Token = await ethers.getContractFactory("ERC20");

  const usdt = await Token.deploy("USDT Token", "USDT", 18);
  await usdt.waitForDeployment();
  console.log(`USDT deployed at: ${await usdt.getAddress()}`);

  const usdc = await Token.deploy("USDC Token", "USDC", 18);
  await usdc.waitForDeployment();
  console.log(`USDC deployed at: ${await usdc.getAddress()}`);

  const dai = await Token.deploy("DAI Token", "DAI", 18);
  await dai.waitForDeployment();
  console.log(`DAI deployed at: ${await dai.getAddress()}`);
}

// Run the script
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});