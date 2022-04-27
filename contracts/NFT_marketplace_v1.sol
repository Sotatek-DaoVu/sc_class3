// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721URIStorageUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "./NFT.sol";

contract NFT_marketplace_v1 is Initializable, OwnableUpgradeable {
    using CountersUpgradeable for CountersUpgradeable.Counter;
    CountersUpgradeable.Counter private _itemIds;
    CountersUpgradeable.Counter private _itemSold;

    NFT nft_token;

    address payable private treasuryAddress;
    mapping(uint256 => MarketItem) public idMarketItem;

    struct MarketItem {
        uint256 tokenId;
        address payable seller;
        uint256 price;
        bool sold;
    }

    // modifier

    modifier HasTransferApproval(uint256 tokenId) {
        require(
            nft_token.getApproved(tokenId) == address(this),
            "Market is not approved"
        );
        _;
    }
    modifier OnlyItemOwner(uint256 tokenId) {
        require(
            nft_token.ownerOf(tokenId) == msg.sender,
            "Sender does not own the item"
        );
        _;
    }

    //function

    function getTreasuryAddress() public view returns (address) {
        return treasuryAddress;
    }

    function setTreasuryAddress(address _newTreasuryAddress) public onlyOwner {
        address oldTreasuryAddress = treasuryAddress;
        treasuryAddress = payable(_newTreasuryAddress);
        emit changeTreasuryAddress(oldTreasuryAddress, _newTreasuryAddress);
    }

    function setNftContract(address _nftAddress) public {
        nft_token = NFT(_nftAddress);
    }

    function getNftContract() public view returns (NFT) {
        return nft_token;
    }

    function initialize() public initializer {
        __Ownable_init();
    }

    function createOrder(uint256 tokenId, uint256 price)
        external
        virtual
        OnlyItemOwner(tokenId)
        HasTransferApproval(tokenId)
    {
        require(price > 0, "Price must be at least 1 wei");

        _itemIds.increment();

        idMarketItem[tokenId] = MarketItem(
            tokenId,
            payable(msg.sender),
            price,
            false
        );
        emit MarketItemCreated(tokenId, msg.sender, price, false);
    }

    function matchOrder(uint256 tokenId)
        external
        payable
        virtual
        OnlyItemOwner(tokenId)
        HasTransferApproval(tokenId)
    {
        uint256 price = idMarketItem[tokenId].price;
        address seller = idMarketItem[tokenId].seller;
        require(
            msg.value == price,
            "The asking price is not match the price of the NFT"
        );

        _itemSold.increment();
        getNftContract().safeTransferFrom(
            idMarketItem[tokenId].seller,
            msg.sender,
            tokenId
        );
        idMarketItem[tokenId].sold = true;
        payable(seller).transfer(msg.value);
        emit ItemSold(idMarketItem[tokenId].seller, msg.sender, tokenId, true);
    }

    // event

    event changeTreasuryAddress(address from, address to);
    event MarketItemCreated(
        uint256 indexed tokenId,
        address seller,
        uint256 price,
        bool sold
    );

    event ItemSold(address from, address to, uint256 tokenId, bool sold);
}
