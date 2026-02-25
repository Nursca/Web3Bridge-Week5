import {
  loadFixture,
} from "@nomicfoundation/hardhat-toolbox/network-helpers";
// import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import { expect } from "chai";
import hre, { ethers } from "hardhat";

describe("Vault", function () {

  async function deployVault() {
    const totalSupply = ethers.parseEther("10000");
    const depositERC20 = ethers.parseEther("10");
    const depositEth = ethers.parseEther("2");

    const [owner, eve] = await hre.ethers.getSigners();

    const ERC20 = await hre.ethers.getContractFactory("ERC20");
    const erc20 = await ERC20.deploy("Nursca", "NUR", owner.address);
    await erc20.transfer(eve.address, depositERC20);

    const Vault = await hre.ethers.getContractFactory("Vault");
    const vault = await Vault.deploy(erc20);

    return { totalSupply, depositERC20, depositEth, vault, erc20, owner, eve };
  }
  

  describe("Ether deposit/withdrawal", function () {
    it("allows depositing Ether", async function () {
      const { vault, eve, depositEth } = await loadFixture(deployVault);
      await expect(
        vault.connect(eve).depositEth({ value: depositEth })
      )
        .to.emit(vault, "DepositSuccessful")
        .withArgs(eve.address, depositEth);

      // getUserSavings() returns msg.sender's balance; call it as eve
      expect(await vault.connect(eve).getUserSavings()).to.equal(depositEth);

      expect(
        await ethers.provider.getBalance(await vault.getAddress())
      ).to.equal(depositEth);

    });

    it("does not allow zero Ether deposit", async function () {
      const { vault, eve } = await loadFixture(deployVault);

      await expect(
        vault.connect(eve).depositEth({ value: 0n })
      ).to.be.revertedWith("Can't deposit zero value");
    });

    it("allows withdrawal of Ether", async function (){
      const { vault, eve, depositEth } = await loadFixture(deployVault);

      await (vault).connect(eve).depositEth({ value: depositEth });

      await expect((vault).connect(eve).withdrawEth(depositEth, { value: depositEth })).to.emit(vault, "WithdrawSuccessful");

      expect(await (vault).getUserSavings()).to.equal(0);

    });

    it("does not withdraw more than balance", async function () {
      const { vault, eve, depositEth } = await loadFixture(deployVault);
      await vault.connect(eve).depositEth({ value: depositEth });

      const overAmount = depositEth + 1n;

      await expect(
        vault.connect(eve).withdrawEth(overAmount, { value: overAmount })
      ).to.be.revertedWith("You didn't save that much");
    });
  });

  describe("ERC20 deposit/withdrawal", function () {
    it("allows depositing ERC20 tokens", async function () {
      const { vault, erc20, eve, depositERC20 } = await loadFixture(deployVault);

      await erc20.connect(eve).approve(vault, depositERC20);

      await expect(
        vault.connect(eve).depositERC20(depositERC20)
      )
        .to.emit(vault, "DepositSuccessful")
        .withArgs(eve.address, depositERC20);

      expect(await vault.connect(eve).getERC20SavingsBalance()).to.equal(
        depositERC20
      );

      expect(await erc20.balanceOf(vault)).to.equal(depositERC20);
    });

    it("does not allow ERC20 deposit with insufficient balance", async function () {
      const { vault, eve, depositERC20 } = await loadFixture(deployVault);

      const overAmount = depositERC20 + 1n;

      await expect(
        vault.connect(eve).depositERC20(overAmount)
      ).to.be.revertedWith("Insufficient funds");
    });

    it("allows ERC20 withdrawal", async function () {
      const { vault, eve, erc20, depositERC20 } = await loadFixture(deployVault);

      await erc20.connect(eve).approve(vault, depositERC20);
      await vault.connect(eve).depositERC20(depositERC20);

      await expect(
        vault.connect(eve).withdrawERC20(depositERC20)
      ).to.emit(vault, "WithdrawSuccessful");

      expect(await vault.connect(eve).getERC20SavingsBalance()).to.equal(0);
      expect(await erc20.balanceOf(eve.address)).to.equal(depositERC20);
    });

    it("does not allow zero ERC20 withdrawal", async function () {
      const { vault, eve } = await loadFixture(deployVault);
      await expect(
        vault.connect(eve).withdrawERC20(0)
      ).to.be.revertedWith("Can't send zero value");
    });
  });
});

