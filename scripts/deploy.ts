import { ethers } from "hardhat"

async function main() {
  const Token = await ethers.getContractFactory("ERC20")
  const Governance = await ethers.getContractFactory("Governance")
  const [deployer, user1, ...users] = await ethers.getSigners()
  const token = await Token.connect(deployer).deploy("Token-T", "TT", 18, 2000)
  const whitelistUsers = users.map((user) => user.address)
  const day = 864000
  const governance = await Governance.connect(user1).deploy(
    "Give grant to team",
    Date.now(),
    Date.now() + day * 5,
    10,
    token.address,
    whitelistUsers
  )
  governance.deployed()
}

main().catch((error) => {
  console.error(error)
  process.exitCode = 1
})
