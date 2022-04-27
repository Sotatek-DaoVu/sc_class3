// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract NFTAirDrop is ERC721 {
    bytes32 public immutable root;

    constructor(bytes32 merkleroot) ERC721("NFTAirDrop", "AD") {
        root = merkleroot;
    }

    function ClaimNFT(
        address account,
        uint256 tokenId,
        bytes32[] calldata proof
    ) external {
        require(_verify(_leaf(account, tokenId), proof), "INVALID PROOF");
        _safeMint(account, tokenId);
    }

    function _verify(bytes32 leaf, bytes32[] memory proof)
        internal
        view
        returns (bool)
    {
        return MerkleProof.verify(proof, root, leaf);
    }

    function _leaf(address account, uint256 tokenId)
        internal
        pure
        returns (bytes32)
    {
        return keccak256(abi.encodePacked(tokenId, account));
    }
}
