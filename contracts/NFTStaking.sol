// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract NFTStaking is ERC721Holder {
    using SafeMath for uint256;

    IERC721 public nftToken;
    IERC20 public rewardToken;
    uint256 public rewardRate = 5 * 10 ** 18; // 5 ERC20 tokens per day per NFT
    uint256 public totalReward = 1000000 * 10 ** 18; // Total reward available for distribution

    mapping(address => uint256[]) private stakedTokens; // Mapping of user to array of staked token IDs
    mapping(uint256 => address) private stakedTokenOwners; // Mapping of staked token ID to owner address
    mapping(uint256 => uint256) private stakingTime; // Mapping of staked token ID to staking start time
    mapping(address => uint256) public userClaimedRewards; // Mapping of user to claimed rewards

    event Staked(address indexed staker, uint256 tokenId);
    event Unstaked(address indexed staker, uint256 tokenId);
    event RewardWithdrawn(address indexed staker, uint256 amount);

    constructor(address _nftToken, address _rewardToken) {
        nftToken = IERC721(_nftToken);
        rewardToken = IERC20(_rewardToken);
    }

    function stake(uint256 tokenId) external {
        require(nftToken.ownerOf(tokenId) == msg.sender, "Not token owner");

        nftToken.safeTransferFrom(msg.sender, address(this), tokenId);
        stakedTokens[msg.sender].push(tokenId);
        stakedTokenOwners[tokenId] = msg.sender;
        stakingTime[tokenId] = block.timestamp;

        emit Staked(msg.sender, tokenId);
    }

    function unstake(uint256 tokenId) external {
        require(
            stakedTokenOwners[tokenId] == msg.sender,
            "Not staked by caller"
        );

        uint256[] storage userStakedTokens = stakedTokens[msg.sender];
        bool found = false;
        for (uint256 i = 0; i < userStakedTokens.length; i++) {
            if (userStakedTokens[i] == tokenId) {
                found = true;
                break;
            }
        }
        require(found, "Token not staked by user");

        nftToken.safeTransferFrom(address(this), msg.sender, tokenId);

        // Remove token from stakedTokens array
        for (uint256 i = 0; i < userStakedTokens.length; i++) {
            if (userStakedTokens[i] == tokenId) {
                userStakedTokens[i] = userStakedTokens[
                    userStakedTokens.length - 1
                ];
                userStakedTokens.pop();
                break;
            }
        }

        emit Unstaked(msg.sender, tokenId);
    }

    function claimReward() external {
        uint256 reward = calculateReward(msg.sender);
        require(reward > 0, "No reward available");

        // Ensure total reward is not exceeded
        require(totalReward >= reward, "Not enough reward available");

        // Transfer reward to user
        rewardToken.transfer(msg.sender, reward);

        // Reduce total reward and update user's claimed reward
        totalReward = totalReward.sub(reward);
        userClaimedRewards[msg.sender] = userClaimedRewards[msg.sender].add(
            reward
        );
    }

    function calculateReward(address staker) public view returns (uint256) {
        uint256 rewardAmount = 0;
        uint256[] storage userStakedTokens = stakedTokens[staker];
        for (uint256 i = 0; i < userStakedTokens.length; i++) {
            uint256 tokenId = userStakedTokens[i];
            uint256 stakedTime = stakingTime[tokenId];
            uint256 stakedDuration = block.timestamp.sub(stakedTime);
            uint256 reward = stakedDuration.mul(rewardRate).div(1 days);
            rewardAmount = rewardAmount.add(reward);
        }
        return rewardAmount;
    }
}
