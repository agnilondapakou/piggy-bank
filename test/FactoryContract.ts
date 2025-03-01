import {
    time,
    loadFixture,
  } from "@nomicfoundation/hardhat-toolbox/network-helpers";
  import { expect } from "chai";
  import hre from "hardhat";

  describe("Factory contract", function () {
    async function deployFactoryContractFixture() {
        const [owner] = await hre.ethers.getSigners();
    }
  })