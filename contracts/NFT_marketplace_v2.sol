// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./NFT_marketplace_v1.sol";

contract NFT_marketplace_v2 is NFT_marketplace_v1 {
    using CountersUpgradeable for CountersUpgradeable.Counter;
    CountersUpgradeable.Counter private _itemIds;
    CountersUpgradeable.Counter private _itemSold;

    function matchOrder(uint256 tokenId)
        external
        payable
        override
        HasTransferApproval(tokenId)
    {
        uint256 price = idMarketItem[tokenId].price;
        address seller = idMarketItem[tokenId].seller;

        uint256 payForSeller = price - ((price / 4) / 100);
        uint256 payForTreasury = ((price / 4) / 100) + ((price / 4) / 100);

        require(
            msg.value >= payForSeller + payForTreasury,
            "Not enough funds sent"
        );

        require(msg.sender != idMarketItem[tokenId].seller);

        _itemSold.increment();

        super.getNftContract().safeTransferFrom(
            idMarketItem[tokenId].seller,
            msg.sender,
            tokenId
        );
        idMarketItem[tokenId].sold = true;
        payable(seller).transfer(msg.value);
        address payable treasuryAddress = payable(super.getTreasuryAddress());
        treasuryAddress.transfer(payForTreasury);
        emit ItemSold(idMarketItem[tokenId].seller, msg.sender, tokenId, true);
    }
}
