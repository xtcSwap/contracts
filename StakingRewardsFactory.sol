pragma solidity ^0.5.16;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.3.0/contracts/token/ERC20/IERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.3.0/contracts/ownership/Ownable.sol";


import "./StakingRewards.sol";

contract StakingRewardsFactory is Ownable {
    // immutables
    address public rewardsToken;
    uint public stakingRewardsGenesis;

    // the staking tokens for which the rewards contract has been deployed
    address[] public stakingTokens;

    // info about rewards for a particular staking token
    struct StakingRewardsInfo {
        address stakingRewards;
        uint rewardAmount;
    }

    // rewards info by staking token
    mapping(address => StakingRewardsInfo) public stakingRewardsInfoByStakingToken;

    constructor(
        address _rewardsToken,
        uint _stakingRewardsGenesis
    ) Ownable() public {
        require(_stakingRewardsGenesis >= block.timestamp, 'StakingRewardsFactory::constructor: genesis too soon');

        rewardsToken = _rewardsToken;
        stakingRewardsGenesis = _stakingRewardsGenesis;
    }

   //新增抵押矿池
    function deploy(address stakingToken, uint rewardAmount) public onlyOwner {
        StakingRewardsInfo storage info = stakingRewardsInfoByStakingToken[stakingToken];
        require(info.stakingRewards == address(0), 'StakingRewardsFactory::deploy: already deployed');

        info.stakingRewards = address(new StakingRewards(/*_rewardsDistribution=*/ address(this), rewardsToken, stakingToken));
        info.rewardAmount = rewardAmount;
        stakingTokens.push(stakingToken);
    }

    //更新所有矿池
    function notifyRewardAmounts() public {
        require(stakingTokens.length > 0, 'StakingRewardsFactory::notifyRewardAmounts: called before any deploys');
        for (uint i = 0; i < stakingTokens.length; i++) {
            notifyRewardAmount(stakingTokens[i]);
        }
    }

    //更新具体抵押矿池
    function notifyRewardAmount(address stakingToken) public {
        require(block.timestamp >= stakingRewardsGenesis, 'StakingRewardsFactory::notifyRewardAmount: not ready');

        StakingRewardsInfo storage info = stakingRewardsInfoByStakingToken[stakingToken];
        require(info.stakingRewards != address(0), 'StakingRewardsFactory::notifyRewardAmount: not deployed');

        if (info.rewardAmount > 0) {
            uint rewardAmount = info.rewardAmount;
            info.rewardAmount = 0;

            require(
                IERC20(rewardsToken).transfer(info.stakingRewards, rewardAmount),
                'StakingRewardsFactory::notifyRewardAmount: transfer failed'
            );
            StakingRewards(info.stakingRewards).notifyRewardAmount(rewardAmount);
        }
    }

 
}