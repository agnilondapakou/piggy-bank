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

    const [owner] = await hre.ethers.getSigners();

    const Token = await hre.ethers.getContractFactory("ERC20");

    const usdtToken = await Token.deploy("USDT Token", "USDT", 18);
    const usdtTokenAddress = usdtToken.target;

    const Piggybank = await hre.ethers.getContractFactory("PiggyBank");
    const piggybank = await Piggybank.deploy(lockedTime);

    return { piggybank, owner, ADDRESS_ZERO, usdtToken, usdtTokenAddress };
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

  describe("Save tokens", function () {
    it("Should save tokens in piggybank", async function () {
      const { piggybank, owner, usdtToken, usdtTokenAddress } = await loadFixture(deployPiggyBankFixture);

      await piggybank.allowTokens(usdtTokenAddress);

      await usdtToken.mint(owner.address, 1000);

      await usdtToken.connect(owner).approve(piggybank, 1000);

      await piggybank.connect(owner).saveToken(piggybank.target, usdtTokenAddress, 1000);

      expect(await usdtToken.balanceOf(piggybank.target)).to.be.equal(1000);
    })
  });

  describe("Withdray tokens", function () {
    it("Should withdraw tokens when the saving duration is not arrived", async function () {
      const { piggybank, owner, usdtToken, usdtTokenAddress } = await loadFixture(deployPiggyBankFixture);

      await piggybank.allowTokens(usdtTokenAddress);

      await usdtToken.mint(owner.address, 1000);

      await usdtToken.connect(owner).approve(piggybank, 1000);

      await piggybank.connect(owner).saveToken(piggybank.target, usdtTokenAddress, 1000);

      const amount = (1000 * 15) / 100;

      await piggybank.connect(owner).withdrawToken(piggybank.target, usdtTokenAddress);

      expect(await usdtToken.balanceOf(owner.address)).to.be.equal(amount);
    });

    it("Should withdraw tokens when the saving duration is arrived", async function () {
      const { piggybank, owner, usdtToken, usdtTokenAddress } = await loadFixture(deployPiggyBankFixture);

      await piggybank.allowTokens(usdtTokenAddress);

      await usdtToken.mint(owner.address, 1000);

      await usdtToken.connect(owner).approve(piggybank, 1000);

      await piggybank.connect(owner).saveToken(piggybank.target, usdtTokenAddress, 1000);

      await time.increase(86400 * 30);

      await piggybank.connect(owner).withdrawToken(piggybank.target, usdtTokenAddress);

      expect(await usdtToken.balanceOf(owner.address)).to.be.equal(1000);
    });
  });
});
