// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13 ^0.8.20;

// lib/openzeppelin-contracts/contracts/utils/Context.sol

// OpenZeppelin Contracts (last updated v5.0.1) (utils/Context.sol)

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    function _contextSuffixLength() internal view virtual returns (uint256) {
        return 0;
    }
}

// lib/openzeppelin-contracts/contracts/access/Ownable.sol

// OpenZeppelin Contracts (last updated v5.0.0) (access/Ownable.sol)

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * The initial owner is set to the address provided by the deployer. This can
 * later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    /**
     * @dev The caller account is not authorized to perform an operation.
     */
    error OwnableUnauthorizedAccount(address account);

    /**
     * @dev The owner is not a valid owner account. (eg. `address(0)`)
     */
    error OwnableInvalidOwner(address owner);

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the address provided by the deployer as the initial owner.
     */
    constructor(address initialOwner) {
        if (initialOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(initialOwner);
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        if (owner() != _msgSender()) {
            revert OwnableUnauthorizedAccount(_msgSender());
        }
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby disabling any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        if (newOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// src/GameContract.sol

/// @title The Faucet Manager
/// @author Adham Ahmed Kamel 
/// @notice This contract manages the faucet
/// @dev This is where you can change the number of kittens required to collect, the import is to use the OnlyOwner modifier

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
    /// @notice The number of kittens required to collect
    /// @dev Please use this variable instead of hardcoding it, same goes for REWARD
    uint256 public constant KITTENS_REQUIRED = 15;
    /// @notice The amount given by the faucet upon collecting the required number of kittens
    uint256 public REWARD = 0.05 ether;
    /// @notice The total number of kittens collected everywhere
    uint256 public totalKittens;

    /// @notice An event that records how many kittens the user has
    /// @dev This is used each time the setKittens function is invoked
    event KittensUpdated(address indexed user, uint256 newValue);
    /// @notice An event that records the reward the user has gained in case it's changed later on
    /// @dev This is used each time the rewardUser function is invoked    
    event UserRewarded(address indexed user, uint256 amount);
    /// @notice An event that records the donations done by users
    /// @dev This is used each time the receive function is used
    event DonationReceived(address indexed user, uint256 amount);

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

    function getTotalKittens() public view returns(uint256) {
        return totalKittens;
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

    /// @notice Withdraws the funds of the contract to facilitate updating
    /// @dev Only the owner can use it
    function withdrawFunds() external onlyOwner {
        require(address(this).balance > 0, 'The contract has 0 funds');
        (bool success, ) = msg.sender.call{value: address(this).balance}("");
        require(success, "Withdrawal failed");
    }
}
