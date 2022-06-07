import { expect } from "chai"
import { ethers } from "hardhat"
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers"
import { ERC20 } from "../typechain"

export interface TokenContext {
  token: ERC20
  deployer: SignerWithAddress
  user1: SignerWithAddress
  user2: SignerWithAddress
  user3: SignerWithAddress
  users: SignerWithAddress[]
}

describe("Token", function () {
  let ctx: TokenContext

  beforeEach(async () => {
    const [deployer, user1, user2, user3, ...users] = await ethers.getSigners()
    const Token = await ethers.getContractFactory("ERC20")
    const token = await Token.deploy("Token-T", "TT", 18, 2000)
    ctx = { token, deployer, user1, user2, user3, users }
  })

  describe("Deployment", () => {
    it("Should assing the total supply of tokens to the owner", async () => {
      const ownerBalance = await ctx.token.balanceOf(ctx.deployer.address)
      expect(await ctx.token.totalSupply()).to.equal(ownerBalance)
    })

    it("Should return decimals token", async () => {
      expect(await ctx.token.decimals()).to.equal(18)
    })
    it("Should return name token", async () => {
      expect(await ctx.token.name()).to.include("Token-T")
    })
    it("Should return symbol token", async () => {
      expect(await ctx.token.symbol()).to.include("TT")
    })
  })

  describe("Transaction", () => {
    it("Should transfer tokens between accounts", async () => {
      // transfer 50 tokens from owner to user1
      await ctx.token.transfer(ctx.user1.address, 50)
      expect(await ctx.token.balanceOf(ctx.user1.address)).to.equal(50)

      // transfer 50 tokens from user 1 to user2
      await ctx.token.connect(ctx.user1).transfer(ctx.user2.address, 50)
      expect(await ctx.token.balanceOf(ctx.user2.address))
    })

    it("Should fail if send doesn't have enugh tokens", async () => {
      const initialOwnerBalance = await ctx.token.balanceOf(ctx.deployer.address)
      await expect(ctx.token.connect(ctx.user1).transfer(ctx.deployer.address, 1)).to.be.revertedWith(
        "ERC20: transfer amount exceeds balance"
      )

      expect(await ctx.token.balanceOf(ctx.deployer.address)).to.equal(initialOwnerBalance)
    })
  })

  it("Should update balance after transfers", async () => {
    const initialOwnerBalance = await ctx.token.balanceOf(ctx.deployer.address)
    const amount1 = 50
    const amount2 = 100

    // transfer to user 1 50 tokens
    await ctx.token.transfer(ctx.user1.address, amount1)
    // transfer to user 2 100 tokens
    await ctx.token.transfer(ctx.user2.address, amount2)

    // check balances
    const finalBalance = await ctx.token.balanceOf(ctx.deployer.address)
    expect(finalBalance).to.equal(initialOwnerBalance.sub(amount1 + amount2))

    const user1Balance = await ctx.token.balanceOf(ctx.user1.address)
    expect(user1Balance).to.equal(amount1)

    const user2Balance = await ctx.token.balanceOf(ctx.user2.address)
    expect(user2Balance).to.equal(amount2)
  })

  describe("Burned", () => {
    it("should burned tokens", async () => {
      const amount = 50
      await ctx.token.transfer(ctx.user1.address, amount)

      const userBalance = await ctx.token.balanceOf(ctx.user1.address)
      expect(userBalance).to.equal(amount)
      await ctx.token.connect(ctx.user1)._burn(amount)
      const userBalanceAfterBurned = await ctx.token.balanceOf(ctx.user1.address)
      expect(userBalanceAfterBurned).to.equal(0)
    })

    it("Should fail burned doesn't have enough tokens", async () => {
      const userBalance = await ctx.token.balanceOf(ctx.user1.address)
      const amount = 50
      expect(userBalance).not.to.equal(amount)

      await expect(ctx.token.connect(ctx.user1)._burn(amount)).to.be.revertedWith("ERC20 not enough funds")
    })
    it("Should burned token from user 1", async () => {
      const amount = 50
      await expect(await ctx.token.transfer(ctx.user1.address, amount))
      await ctx.token.connect(ctx.user1).approve(ctx.deployer.address, amount)
      expect(await ctx.token.allowance(ctx.user1.address, ctx.deployer.address)).to.equal(amount)
      await ctx.token.burnFrom(ctx.user1.address, amount)
      expect(await ctx.token.allowance(ctx.deployer.address, ctx.user1.address)).to.equal(0)
    })
    it("Should fail not enough funds on account", async () => {
      const amount = 50
      await ctx.token.connect(ctx.user1).approve(ctx.deployer.address, amount)
      expect(await ctx.token.connect(ctx.deployer.address).allowance(ctx.user1.address, ctx.deployer.address)).to.equal(
        50
      )
      await expect(ctx.token.burnFrom(ctx.user1.address, amount)).to.be.revertedWith(
        "ERC20: not enough funds on account"
      )
    })
  })

  describe("Approve", () => {
    it("Check approve", async () => {
      await ctx.token.approve(ctx.user1.address, 10)
      expect(await ctx.token.allowance(ctx.deployer.address, ctx.user1.address)).to.equal(10)
    })
    it("Should doesn't approve zero address", async () => {
      await expect(ctx.token.approve(ethers.constants.AddressZero, 5)).to.be.revertedWith(
        "ERC20: approve to the zero address"
      )
    })
  })

  describe("Allowance", () => {
    it("Check allowance default value", async () => {
      const allowance = await ctx.token.allowance(ctx.deployer.address, ctx.user1.address)
      expect(allowance).to.equal(0)
    })

    it("Set allowance", async () => {
      await ctx.token.approve(ctx.user1.address, 10)
      expect(await ctx.token.allowance(ctx.deployer.address, ctx.user1.address)).to.equal(10)
    })

    it("Should be update value allowance", async () => {
      const amount = 50

      await ctx.token.connect(ctx.user1).approve(ctx.deployer.address, amount)
      await ctx.token.allowance(ctx.user1.address, ctx.deployer.address)

      await ctx.token.transfer(ctx.user1.address, amount)

      await ctx.token.transferFrom(ctx.user1.address, ctx.user2.address, amount)

      const balanceUser2 = await ctx.token.balanceOf(ctx.user2.address)

      expect(balanceUser2).to.equal(amount)
    })
  })

  describe("increase and decrease allowance", () => {
    it("Should be double increase allowance", async () => {
      const amount = 50
      await ctx.token.connect(ctx.user1).increaseAllowance(ctx.deployer.address, amount)
      const checkFirstAddAllowance = await ctx.token.allowance(ctx.user1.address, ctx.deployer.address)
      expect(checkFirstAddAllowance).to.eq(amount)
      await ctx.token.connect(ctx.user1).increaseAllowance(ctx.deployer.address, amount)
      const checkSecondAddAllowance = await ctx.token.allowance(ctx.user1.address, ctx.deployer.address)
      expect(checkSecondAddAllowance).to.eq(amount * 2)
      await ctx.token.transfer(ctx.user1.address, amount)

      await ctx.token.transferFrom(ctx.user1.address, ctx.user2.address, amount)

      const balanceUser2 = await ctx.token.balanceOf(ctx.user2.address)

      expect(balanceUser2).to.equal(amount)
    })
    it("Should be double increase allowance, and one decrease", async () => {
      const amount = 50
      await ctx.token.connect(ctx.user1).increaseAllowance(ctx.deployer.address, amount)
      await ctx.token.allowance(ctx.user1.address, ctx.deployer.address)
      await ctx.token.connect(ctx.user1).increaseAllowance(ctx.deployer.address, amount)
      await ctx.token.allowance(ctx.user1.address, ctx.deployer.address)

      await ctx.token.connect(ctx.user1).decreaseAllowance(ctx.deployer.address, amount)
      const checkAllowance = await ctx.token.allowance(ctx.user1.address, ctx.deployer.address)
      expect(checkAllowance).to.eq(amount * 2 - amount)
      await ctx.token.transfer(ctx.user1.address, amount)

      await ctx.token.transferFrom(ctx.user1.address, ctx.user2.address, amount)

      const balanceUser2 = await ctx.token.balanceOf(ctx.user2.address)

      expect(balanceUser2).to.equal(amount)
    })
  })
})
