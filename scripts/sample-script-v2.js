const { ethers, upgrades } = require("hardhat");

const PROXY_ADDRESS = "0x9b53E0bF79bC0e05C0ce27B46EfE56333a318e54";
const TREASURY = "0x00129489005337e7be29a784019be49516ca088A";

async function main() {
  const NFTMPV2 = await ethers.getContractFactory("NFT_marketplace_v2");
  await upgrades.upgradeProxy(PROXY_ADDRESS, NFTMPV2, [TREASURY]);
  console.log(`proxy upgraded`);
}

main();
