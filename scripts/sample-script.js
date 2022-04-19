const { ethers, upgrades } = require("hardhat");

async function main() {
  const NFTMPV1 = await ethers.getContractFactory("NFT_marketplace_v1");
  const nft_mp_v1 = await upgrades.deployProxy(NFTMPV1);

  await nft_mp_v1.deployed();

  console.log("nft_mp_v1 deployed to:", nft_mp_v1.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
