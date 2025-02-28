import {
  time,
  loadFixture,
} from "@nomicfoundation/hardhat-toolbox/network-helpers";
import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import { expect } from "chai";
import hre from "hardhat";

describe("PiggyBank", function () {
  async function deployPiggyBankFixture() {
    // today plus one month
    const lockedTime = (await time.latest()) + (86400 * 30);

    const ADDRESS_ZERO = "0x0000000000000000000000000000000000000000";

    const [owner, bankAddress] = await hre.ethers.getSigners();

    const Token = await hre.ethers.getContractFactory("ERC20");
    const token = await Token.deploy("DAI Token", "DAI", 18);

    const Piggybank = await hre.ethers.getContractFactory("PiggyBank");
    const piggybank = await Piggybank.deploy(lockedTime);

    return { piggybank, owner, ADDRESS_ZERO, token, bankAddress };
  }

  describe("Deployment", function () {
    it("Should deploy the piggy bank contract", async function () {
      const { piggybank, ADDRESS_ZERO } = await loadFixture(deployPiggyBankFixture);

      expect(piggybank.target).to.be.not.equal(ADDRESS_ZERO);
    });

    it("Should check if the owner is not address 0", async function () {
      const { owner, ADDRESS_ZERO } = await loadFixture(deployPiggyBankFixture);

      expect(owner).to.be.not.equal(ADDRESS_ZERO);
    })
  });

  describe("Save money", function () {
    it("Should save money in piggybank", async function () {
      const { owner, piggybank, token, bankAddress } = await loadFixture(deployPiggyBankFixture);

      token.mint(owner.address, 1000);

      piggybank.connect(owner).saveToken(owner, bankAddress, 1000);

      const tokenAddress = '0x4b61Df4dA7c04877113e772CeA1baE79Cf666926';

      expect(await token.connect(tokenAddress).balanceOf(bankAddress)).to.be.equal(1000);
    })
  })
});
