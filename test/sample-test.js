const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("NFTMarket", function () {
  it("Should Create successful", async function () {
    const NFT_MP_V1 = ethers.getContractFactory("NFT_marketplace_v1");
    const market_1 = await NFT_MP_V1.deployProxy(NFT_MP_V1);

    const priceNFT = ethers.utils.parseUnits("1", "ether");

    await market_1.createNFT("https://www.myNft.com", priceNFT); // idToken 1
    await market_1.createNFT("https://www.myNft.com", priceNFT); // idToken 2
  });

  it("Should return right address after sell", async function () {
    const [buyerAddress] = await ethers.getSigners();
    await market_1.connect(buyerAddress).createOrder(1, priceNFT);
    expect(await market_1.getOwnerOfNFT(1)).to.equal(buyerAddress.address);
  });

  it("Item was sold", async function () {
    expect(await market_1.getNFTSold(1)).to.equal(true);
  });
});
