import { expect } from 'chai'
import { ethers } from 'hardhat'
import { Governance } from '../typechain'
import { TokenContext } from './erc20'

interface GovernanceContext {
  governance: Governance
}
describe('Governance', () => {
  let ctx: TokenContext
  let governanceCtx: GovernanceContext

  beforeEach(async () => {
    const Token = await ethers.getContractFactory('ERC20')
    const Governance = await ethers.getContractFactory('Governance')
    const [deployer, user1, user2, ...users] = await ethers.getSigners()
    const token = await Token.deploy('Token-T', 'TT', 18, 2000)
    const whitelistUsers = users.map((user) => user.address)
    const governance = await Governance.deploy('Vote', 'Give grant to team', 1652025305, 1652370905, 10, whitelistUsers)
    governance.deployed()
    ctx = { deployer, token, user1, user2, users }
    governanceCtx = { governance }
  })

  describe('Deployment', () => {
    it('Should return governance name', async () => {
      expect(await governanceCtx.governance.getGovernanceName()).to.eq('Vote')
    })
    it('Should return proposal', async () => {
      expect(await governanceCtx.governance.getProposal()).to.eq('Give grant to team')
    })
  })
  describe('Check change timestamp', () => {
    it('Should be change start timestamp', async () => {
      const newStartData = 1652370905
      await governanceCtx.governance.changeStartTimestamp(newStartData)
      expect(await governanceCtx.governance.getStartTimestamp()).to.eq(newStartData)
    })
    // eslint-disable-next-line quotes
    it(`Should can't be change start timestamp`, async () => {
      const newStartData = 1652370905
      await expect(governanceCtx.governance.connect(ctx.user1).changeStartTimestamp(newStartData)).to.be.revertedWith(
        'must be address onwer'
      )
    })

    it('Should be change end timestamp', async () => {
      const newEndData = 1652457305
      await governanceCtx.governance.changeEndTimestamp(newEndData)
      expect(await governanceCtx.governance.getEndTimestamp()).to.eq(newEndData)
    })
    // eslint-disable-next-line quotes
    it(`Should can't be change end timestamp`, async () => {
      const newStartData = 1652370905
      await expect(governanceCtx.governance.connect(ctx.user1).changeEndTimestamp(newStartData)).to.be.revertedWith(
        'must be address onwer'
      )
    })
  })
  describe('Whitelist', () => {
    it('Should not in the whitelist', async () => {
      expect(await governanceCtx.governance.checkAddressWhitelist(ethers.constants.AddressZero)).to.be.equal(false)
    })
    it('Should set addresses to the whitelist', async () => {
      await governanceCtx.governance.setWhitelist([ctx.user1.address, ctx.user2.address])
      expect(await governanceCtx.governance.checkAddressWhitelist(ctx.user1.address)).to.be.equal(true)
    })
    it('Should can not set address at the whitelist', async () => {
      await expect(
        governanceCtx.governance.connect(ctx.user1).setWhitelist([ctx.user1.address, ctx.user2.address])
      ).to.be.revertedWith('must be address onwer')
    })
  })

  // describe('Vote', () => {
  //   it('', () => {

  //   })
  // })
})
