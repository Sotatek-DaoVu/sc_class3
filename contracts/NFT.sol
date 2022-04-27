// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721URIStorageUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

contract NFT is Initializable, ERC721URIStorageUpgradeable, OwnableUpgradeable {
    using CountersUpgradeable for CountersUpgradeable.Counter;

    CountersUpgradeable.Counter private _itemIds;

    address private marketAddress;

    function initialize() public initializer {
        __ERC721_init("SmartContract", "SC");
        __Ownable_init();
    }

    function createNFT(string memory _tokenURI) public returns (uint256) {
        _itemIds.increment();
        uint256 _newTokenId = _itemIds.current();
        _safeMint(msg.sender, _newTokenId);
        _setTokenURI(_newTokenId, _tokenURI);
        _approve(marketAddress, _newTokenId);
        return _newTokenId;
    }
}
