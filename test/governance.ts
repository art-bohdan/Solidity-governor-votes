import { expect } from "chai"
import { ethers } from "hardhat"
import { Governance } from "../typechain"
import { TokenContext } from "./erc20"

interface GovernanceContext {
  governance: Governance
}
describe("Governance", () => {
  let ctx: TokenContext
  let governanceCtx: GovernanceContext

  beforeEach(async () => {
    const Token = await ethers.getContractFactory("ERC20")
    const Governance = await ethers.getContractFactory("Governance")
    const [deployer, user1, user2, user3, ...users] = await ethers.getSigners()
    const token = await Token.deploy("Token-T", "TT", 18, 2000)
    const whitelistUsers = users.map((user) => user.address)
    const governance = await Governance.connect(user1).deploy(
      "Vote",
      "Give grant to team",
      1652371906,
      1652631106,
      10,
      token.address,
      whitelistUsers
    )
    governance.deployed()
    ctx = { deployer, token, user1, user2, user3, users }
    governanceCtx = { governance }
  })

  describe("Deployment", () => {
    it("Should return governance name", async () => {
      expect(await governanceCtx.governance.getGovernanceName()).to.eq("Vote")
    })
    it("Should return proposal", async () => {
      expect(await governanceCtx.governance.getProposal()).to.eq("Give grant to team")
    })
  })
  describe("Check change timestamp", () => {
    it("Should be change start timestamp", async () => {
      const newStartData = 1652370905
      await governanceCtx.governance.changeStartTimestamp(newStartData)
      expect(await governanceCtx.governance.getStartTimestamp()).to.eq(newStartData)
    })
    // eslint-disable-next-line quotes
    it(`Should can't be change start timestamp`, async () => {
      const newStartData = 1652458306
      await expect(governanceCtx.governance.connect(ctx.user2).changeStartTimestamp(newStartData)).to.be.revertedWith(
        "Sender address must be onwer"
      )
    })

    it("Should be change end timestamp", async () => {
      const newEndData = 1652457305
      await governanceCtx.governance.changeEndTimestamp(newEndData)
      expect(await governanceCtx.governance.getEndTimestamp()).to.eq(newEndData)
    })
    // eslint-disable-next-line quotes
    it(`Should can't be change end timestamp`, async () => {
      const newStartData = 1652370905
      await expect(governanceCtx.governance.connect(ctx.user2).changeEndTimestamp(newStartData)).to.be.revertedWith(
        "Sender address must be onwer"
      )
    })
  })
  describe("Whitelist", () => {
    it("Should not in the whitelist", async () => {
      expect(await governanceCtx.governance.checkAddressWhitelist(ethers.constants.AddressZero)).to.be.equal(false)
    })
    it("Should set addresses to the whitelist", async () => {
      await governanceCtx.governance.setWhitelist([ctx.user2.address, ctx.user3.address])
      expect(await governanceCtx.governance.checkAddressWhitelist(ctx.user2.address)).to.be.equal(true)
    })
    it("Should can not set address at the whitelist", async () => {
      await expect(
        governanceCtx.governance.connect(ctx.user2).setWhitelist([ctx.user2.address, ctx.user3.address])
      ).to.be.revertedWith("Sender address must be onwer")
    })
  })

  describe("Votes", () => {
    it("Shoud set vote", async () => {
      const amount = 50
      await ctx.token.transfer(ctx.user2.address, amount)
      expect(await ctx.token.balanceOf(ctx.user2.address)).to.eq(amount)
      await governanceCtx.governance.setWhitelist([ctx.user2.address])
      await governanceCtx.governance.connect(ctx.user2).vote(0)
      expect(await governanceCtx.governance.connect(ctx.user2).getVoteOf(ctx.user2.address)).to.be.eq(0)
    })
    it("Shoud not set vote, reverted vote voter alredy voted", async () => {
      const amount = 50
      await ctx.token.transfer(ctx.user2.address, amount)
      expect(await ctx.token.balanceOf(ctx.user2.address)).to.eq(amount)
      await governanceCtx.governance.setWhitelist([ctx.user2.address])
      await governanceCtx.governance.connect(ctx.user2).vote(0)
      expect(await governanceCtx.governance.connect(ctx.user2).getVoteOf(ctx.user2.address)).to.be.eq(0)
      await expect(governanceCtx.governance.connect(ctx.user2).vote(1)).to.be.revertedWith("The voter already voted")
    })
    it("Shoud not set vote, reverted vote voter alredy voted", async () => {
      await governanceCtx.governance.setWhitelist([ctx.user2.address])
      await expect(governanceCtx.governance.connect(ctx.user2).vote(0)).to.be.revertedWith("Not enought funds")
    })
  })
})
