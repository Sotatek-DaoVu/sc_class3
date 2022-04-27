const { ethers } = require("hardhat");
const { MerkleTree } = require("merkletreejs");
const keccak256 = require("keccak256");
const { expect } = require("chai");
const tokens = require("./tokens.json");

async function deploy(...prams) {
  const NFT_AIRDROP = await ethers.getContractFactory("NFTAirDrop");
  const nft_airdrop = await NFT_AIRDROP.deploy(...prams);

  await nft_airdrop.deployed();
}
function hashToken(tokenId, account) {
  return Buffer.from(
    ethers.utils
      .solidityKeccak256(["uint256", "address"], [tokenId, account])
      .slice(2),
    "hex"
  );
}

describe("ERC721Drop", function () {
  before(async function () {
    this.accounts = await ethers.getSigners();
    this.merkleTree = new MerkleTree(
      Object.entries(tokens).map((token) => hashToken(...token)),
      keccak256,
      { sortPairs: true }
    );
  });

  describe("Mintelements", function () {
    before(async function () {
      this.registry = await deploy(this.merkleTree.getHexRoot());
    });

    for (const [tokenId, account] of Object.entries(tokens)) {
      it("element", async function () {
        const proof = this.merkleTree.getHexProof(hashToken(tokenId, account));
        await expect(this.registry.ClaimNFT(account, tokenId, proof))
          .to.emit(this.registry, "Transfer")
          .withArgs(ethers.constants.AddressZero, account, tokenId);
      });
    }
  });
});
