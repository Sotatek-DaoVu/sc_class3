pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721URIStorageUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

contract NFT_marketplace_v1 is ERC721URIStorageUpgradeable, OwnableUpgradeable {
    using CountersUpgradeable for CountersUpgradeable.Counter;
    CountersUpgradeable.Counter private _itemIds;
    CountersUpgradeable.Counter private _itemSold;

    mapping(uint256 => MarketItem) private idMarketItem;

    struct MarketItem {
        uint256 tokenId;
        address payable seller;
        address payable onwer;
        uint256 price;
        bool sold;
    }

    event MarketItemCreated(
        uint256 indexed tokenId,
        address seller,
        address owner,
        uint256 price,
        bool sold
    );

    function initialize() public initializer {
        __ERC721_init("Smart Contract", "SC");
        __Ownable_init();
    }

    function createNFT(string memory tokenURI, uint256 price)
        public
        returns (uint256)
    {
        _itemIds.increment();

        uint256 newTokenId = _itemIds.current();

        _mint(msg.sender, newTokenId);
        _setTokenURI(newTokenId, tokenURI);
        createOrder(newTokenId, price);

        return newTokenId;
    }

    function createOrder(uint256 tokenId, uint256 price) private {
        require(price > 0, "Price must be at least 1 wei");
        idMarketItem[tokenId] = MarketItem(
            tokenId,
            payable(msg.sender),
            payable(address(0)),
            price,
            false
        );
        _transfer(msg.sender, address(this), tokenId);
        emit MarketItemCreated(
            tokenId,
            msg.sender,
            address(this),
            price,
            false
        );
    }

    function buyNFT(uint256 tokenId) public payable {
        uint256 price = idMarketItem[tokenId].price;
        address seller = idMarketItem[tokenId].seller;
        require(
            msg.value == price,
            "The asking price is not match the price of the NFT"
        );
        idMarketItem[tokenId].onwer = payable(msg.sender);
        idMarketItem[tokenId].sold = true;
        idMarketItem[tokenId].seller = payable(address(0));

        _itemSold.increment();

        _transfer(address(this), msg.sender, tokenId);
        payable(seller).transfer(price);
    }

    function getOwnerOfNFT(uint256 tokenId) public view returns (address) {
        address ownerOfNft = idMarketItem[tokenId].onwer;
        return ownerOfNft;
    }

    function getNFTSold(uint256 tokenId) public view returns (bool) {
        return idMarketItem[tokenId].sold;
    }
}
