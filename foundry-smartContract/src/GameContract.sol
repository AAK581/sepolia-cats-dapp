//SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

/// @title The Faucet Manager
/// @author AAK581 
/// @notice This contract manages the faucet
/// @dev This is where you can change the number of kittens required to collect, the import is to use the OnlyOwner modifier

import "@openzeppelin/contracts/access/Ownable.sol";
import "./MilestoneNFT.sol";

contract GameContract is Ownable {
    /// @notice The address of the game for gas
    /// @dev This handles setKittens function
    address public gameAddress;
    /// @notice Makes the deployer of the contract the owner
    /// @dev Sets the inherited Ownable.sol contract's _owner as the msg.sender value
    constructor() Ownable(msg.sender) {}

    modifier onlyGame() {
        require(msg.sender == gameAddress, "Only game can call");
        _;
    }

    /// @notice A mapping of the addresses of the users as well as their collected kittens
    /// @dev Please use this instead of trying to send the number of kittens as a normal value
    mapping(address => uint256) public userKittens;
    /// @notice A mapping of the addresses of the users as well as the last day they claimed rewards
    /// @dev This gets changed in the rewardUser function
    mapping(address => uint256) public lastClaimDay;
    /// @notice A mapping of the addresses of the users as well as the rewards they've claimed during the day
    /// @dev This helps make sure that the user can only claim 4 rewards a day at most
    mapping(address => uint256) public dailyRewards;
    /// @notice Tracks total kittens ever collected by a user, never resets
    /// @dev Used to trigger NFT mint at 300 kittens
    mapping(address => uint256) public lifetimeKittens;
    /// @notice The NFT contract that mints milestone rewards
    /// @dev Set once by owner after NFT deployment
    MilestoneNFT public milestoneNFT;
    /// @notice The number of kittens required to collect
    /// @dev Please use this variable instead of hardcoding it, same goes for REWARD
    uint256 public constant KITTENS_REQUIRED = 15;
    /// @notice The amount given by the faucet upon collecting the required number of kittens
    uint256 public REWARD = 20.0 ether;
    /// @notice The total number of kittens collected everywhere
    uint256 public totalKittens;
    /// @notice Number of kittens needed to mint the milestone NFT
    uint256 public constant MILESTONE_KITTENS = 20;

    /// @notice An event that records how many kittens the user has
    /// @dev This is used each time the setKittens function is invoked
    event KittensUpdated(address indexed user, uint256 newValue);
    /// @notice An event that records the reward the user has gained in case it's changed later on
    /// @dev This is used each time the rewardUser function is invoked    
    event UserRewarded(address indexed user, uint256 amount);
    /// @notice An event that records the donations done by users
    /// @dev This is used each time the receive function is used
    event DonationReceived(address indexed user, uint256 amount);
    /// @notice Emitted when a player reaches 300 lifetime kittens
    /// @dev This happens during SetKittens
    event MilestoneReached(address indexed user, uint256 lifetime);
    /// @notice Emitted when the NFT is successfully minted
    /// @dev This is used in SetKittens
    event NFTMinted(address indexed user, uint256 tokenId);

    /// @notice A function that supplies ETH to the contract, Sepolia in this case
    /// @dev Use this if the faucet runs out of ETH
    function fundContract() external payable onlyOwner {
        require(msg.value > 0, 'Send ETH, please');
    }

    /// @notice Allows users to donate
    /// @dev It emits donations to an event
    receive() external payable {
        require(msg.value > 0, "Send ETH, please");
        emit DonationReceived(msg.sender, msg.value);
    }

    /// @notice A function that maps the number of kittens the user has collected to their address
    /// @dev Use this sparingly, it costs gas
    function setKittens(address userAddress, uint256 _value) public onlyGame {
        require(_value <= 60, "Cannot add more than 60 kittens at once");
        uint256 oldKittenCount = userKittens[userAddress];
        uint256 newKittenCount = oldKittenCount + _value;
        require(newKittenCount <= 60, "Total kittens cannot exceed 60");
        userKittens[userAddress] = newKittenCount;
        totalKittens = totalKittens - oldKittenCount + newKittenCount;

        uint256 oldLifetime = lifetimeKittens[userAddress];
        lifetimeKittens[userAddress] = oldLifetime + _value;

        if (lifetimeKittens[userAddress] >= MILESTONE_KITTENS && oldLifetime < MILESTONE_KITTENS)
        {
            emit MilestoneReached(userAddress, lifetimeKittens[userAddress]);

            try milestoneNFT.mint(userAddress) returns (uint256 tokenId) {
                emit NFTMinted(userAddress, tokenId);
            }
            catch {
                //Fail silently
            }
        }
        emit KittensUpdated(userAddress, newKittenCount);
    }

    /// @notice A function that returns the current day
    /// @dev 86400 is how many seconds there are in a day
    function getToday() private view returns(uint256) {
        return block.timestamp / 86400;
    }

    /// @notice Returns the number of kittens the user has collected
    /// @dev Use this as much as you need
    function getKittens() public view returns(uint256) {
        return userKittens[msg.sender];
    }

    /// @notice Returns the total number of kittens collected by all users
    /// @dev Use this as much as you need
    function getTotalKittens() public view returns(uint256) {
        return totalKittens;
    }

    /// @notice Returns total kittens ever collected by a user
    /// @dev Use this as much as you need
    function getLifetimeKittens(address user) public view returns(uint256) {
        return lifetimeKittens[user];
    }


    /// @notice Rewards the user the designated amount of ETH
    /// @dev This is external, it will be used by the dApp
    function rewardUser() external {
        uint256 kittens = userKittens[msg.sender];
        require(kittens >= KITTENS_REQUIRED, "Collect more kittens");

        uint256 today = getToday();
        if (lastClaimDay[msg.sender] != today) {
            dailyRewards[msg.sender] = 0;
            lastClaimDay[msg.sender] = today;
        }

        uint256 rewardMultiple = kittens / KITTENS_REQUIRED;

        require(dailyRewards[msg.sender] + rewardMultiple <= 4, "Daily reward limit reached");

        uint256 totalReward = rewardMultiple * REWARD;
        require(address(this).balance >= totalReward, "Insufficient balance, apologies");

        dailyRewards[msg.sender] += rewardMultiple;
        uint256 newKittenCount = kittens % KITTENS_REQUIRED;
        userKittens[msg.sender] = newKittenCount;


        (bool success, ) = msg.sender.call{value: totalReward}("");
        require(success, 'Reward transfer failed');
        emit UserRewarded(msg.sender, totalReward);
    }

    /// @notice Changes the reward
    /// @dev Only the owner can use it
    function changeReward(uint256 newReward) external onlyOwner {
        REWARD = newReward;
    }

    /// @notice Sets the address of the game
    /// @dev Only the owner can use it
    function setGameAddress(address _gameAddress) external onlyOwner {
        require(_gameAddress != address(0), "Invalid address");
        gameAddress = _gameAddress;
    }

    /// @notice Links the milestone NFT contract
    /// @dev Must be called once after NFT deployment
    function setMilestoneNFT(address _nft) external onlyOwner {
        require(_nft != address(0), "Invalid NFT address");
        milestoneNFT = MilestoneNFT(_nft);
    }

    /// @notice Withdraws the funds of the contract to facilitate updating
    /// @dev Only the owner can use it
    function withdrawFunds() external onlyOwner {
        require(address(this).balance > 0, 'The contract has 0 funds');
        (bool success, ) = msg.sender.call{value: address(this).balance}("");
        require(success, "Withdrawal failed");
    }
}