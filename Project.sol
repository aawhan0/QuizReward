// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Interface to interact with ERC-20 token standard
interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

contract QuizReward {
    address public owner;              // Owner of the contract (usually the admin or platform)
    IERC20 public rewardToken;         // The ERC-20 token used as rewards
    mapping(address => uint256) public rewards; // Mapping to track user rewards

    // Events to log reward distribution
    event QuizCompleted(address indexed user, uint256 rewardAmount);
    event RewardGranted(address indexed user, uint256 rewardAmount);

    // Modifier to ensure only the owner can perform certain actions
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action");
        _;
    }

    // Constructor to initialize the contract with the reward token address
    constructor(address _rewardToken) {
        owner = msg.sender;            // Set the contract owner
        rewardToken = IERC20(_rewardToken); // Set the ERC-20 reward token
    }

    // Function to fund the contract with tokens (only the owner can fund)
    function fundContract(uint256 amount) external onlyOwner {
        require(rewardToken.transferFrom(msg.sender, address(this), amount), "Funding failed");
    }

    // Function to allow a user to complete a quiz and receive a reward
    function completeQuiz(address user, uint256 rewardAmount) external {
        require(rewardAmount > 0, "Reward amount must be greater than zero");
        require(rewardToken.balanceOf(address(this)) >= rewardAmount, "Insufficient funds in contract");

        rewards[user] += rewardAmount;

        // Emit events for tracking
        emit QuizCompleted(user, rewardAmount);
        emit RewardGranted(user, rewardAmount);

        // Transfer the reward to the user
        require(rewardToken.transfer(user, rewardAmount), "Reward transfer failed");
    }

    // Function for users to check how much reward they have earned
    function checkRewards(address user) external view returns (uint256) {
        return rewards[user];
    }

    // Function for the owner to withdraw tokens from the contract (if necessary)
    function withdraw(uint256 amount) external onlyOwner {
        require(rewardToken.balanceOf(address(this)) >= amount, "Insufficient funds in contract");
        require(rewardToken.transfer(owner, amount), "Withdraw failed");
    }
}
