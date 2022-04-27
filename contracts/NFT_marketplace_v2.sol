// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./NFT_marketplace_v1.sol";
import "./QTCoin.sol";

contract NFT_marketplace_v2 is NFT_marketplace_v1 {
    QTCoin private rewardToken;

    uint256 public rewardRate;
    uint256 public lastUpdateTime;
    uint256 public rewardPerTokenStored;
    uint256 public _totalHashRate;

    mapping(address => uint256) public userRewardPerTokenPaid;
    mapping(address => uint256) public rewards;
    mapping(address => uint256) private _hashRateToUser;
    mapping(uint256 => uint256) private hashRates; /// tokenID ==>> hashrate

    function initialize(address _rewardTokenAddress) public initializer {
        __Ownable_init();
        rewardToken = QTCoin(_rewardTokenAddress);
    }

    function setHashRate(uint256 tokenId, uint256 _hashRate)
        external
        onlyOwner
    {
        hashRates[tokenId] = _hashRate;
    }

    function getHashRate(uint256 tokenId) public view returns (uint256) {
        return hashRates[tokenId];
    }

    function _stake(uint256 tokenId)
        external
        updateReward(msg.sender)
        checkHasHashRate(tokenId)
    {
        _totalHashRate += getHashRate(tokenId);
        _hashRateToUser[msg.sender] += getHashRate(tokenId);
        nft_token.safeTransferFrom(msg.sender, address(this), tokenId);

        emit Staked(msg.sender, tokenId);
    }

    function withdraw(uint256 tokenId)
        public
        updateReward(msg.sender)
        OnlyItemOwner(tokenId)
    {
        _totalHashRate -= getHashRate(tokenId);
        _hashRateToUser[msg.sender] -= getHashRate(tokenId);

        nft_token.safeTransferFrom(address(this), msg.sender, tokenId);

        emit Withdraw(msg.sender, tokenId);
    }

    function getReward() public updateReward(msg.sender) {
        uint256 reward = rewards[msg.sender];

        if (reward > 0) {
            rewards[msg.sender] = 0;
            rewardToken.transfer(msg.sender, reward);
            emit RewardPaid(msg.sender, reward);
        }
    }

    function rewardPerToken() public view returns (uint256) {
        if (_totalHashRate == 0) {
            return 0;
        }
        return
            rewardPerTokenStored +
            ((rewardRate * (block.timestamp - lastUpdateTime) * 1e18) /
                _totalHashRate);
    }

    function earned(address account) public view returns (uint256) {
        return
            ((_hashRateToUser[account] *
                (rewardPerToken() - userRewardPerTokenPaid[account])) / 1e18) +
            rewards[account];
    }

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

    // modifier

    modifier updateReward(address account) {
        rewardPerTokenStored = rewardPerToken();
        lastUpdateTime = block.timestamp;
        rewards[account] = earned(account);
        userRewardPerTokenPaid[account] = rewardPerTokenStored;
        _;
    }

    modifier checkHasHashRate(uint256 tokenId) {
        require(hashRates[tokenId] > 0, "NFT should be set hashRate");
        _;
    }

    // event

    event Staked(address indexed user, uint256 tokenId);
    event Withdraw(address indexed user, uint256 tokenId);
    event RewardPaid(address indexed user, uint256 reward);
}
