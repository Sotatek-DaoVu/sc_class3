const { expect } = require("chai");
const { ethers, upgrades } = require("hardhat");

const TREASURY = "0x00129489005337e7be29a784019be49516ca088A";

describe("NFTMarket", function () {
  it("Should create successfull", async function () {
    const NFT_MP_V1 = ethers.getContractFactory("NFT_marketplace_v1");
    const market_1 = await NFT_MP_V1.deployProxy(NFT_MP_V1);

    const NFT_MP_V2 = ethers.getContractFactory("NFT_marketplace_v2");
    const upgreaded = await upgrades.upgradeProxy(market_1.address, NFT_MP_V2, [
      TREASURY,
    ]);

    const priceNFT = ethers.utils.parseUnits("1", "ether");

    await upgreaded.createNFT("https://www.myNft.com", priceNFT); // idToken 1
    await upgreaded.createNFT("https://www.myNft.com", priceNFT); // idToken 2
    const [buyerAddress, treasury] = await ethers.getSigners();
    const balanceBeforeBuy = await buyerAddress.getBalance();

    it("Should return right address after sell", async function () {
      await upgreaded
        .connect(buyerAddress)
        .buyNFT(1, { value: priceNFT + priceNFT / 400 });
      expect(await upgreaded.getOwnerOfNFT(1)).to.equal(buyerAddress.address);
    });

    it("Test balance of buyer", async function () {
      const balanceAfterBuy = balanceBeforeBuy - (priceNFT + priceNFT / 400);
      expect(await buyerAddress.getBalance()).to.equal(balanceAfterBuy);
    });

    it("Item was sold", async function () {
      expect(await upgreaded.getNFTSold(1)).to.equal(true);
    });

    it("set/get treasury address", async function () {
      await upgreaded.setTreasury(treasury.address);
      expect(await upgreaded.getTreasure()).to.equal(treasury.address);
    });
  });
});
