# About this project

## Project Description
Sepolia Cats is a gamified Sepolia Ethereum faucet made on top of the Scroll L2 network.
Users can claim Scroll Sepolia ETH by collecting kittens in the Scroll Sepolia game which can be synced online using the Teleporter
in-game item.
Upon collecting at least 15 kittens, a user can claim a reward from the dApp, with a maximum of 4 rewards per day.
The game was made using RPG Maker MZ, the dApp was made using a React app using Reown Appkit and Wagmi, and the smart contract was tested
using Foundry.

## Directory Structure

### /react-reown:
Contains the front-end React app (src/App.jsx, src/App.css, package.json, etc.).

### /foundry-smartContract:
Contains the smart contract, the test file, and other important files related to Foundry as well as OpenZeppelin's Ownable contract.

### /sepolia-cats-game
Contains the files of the game itself, made using RPG Maker MZ.


# Design Patterns
### Inheritance and interfaces
Imported OpenZeppelin's Ownable contract (Ownable(msg.sender)).
### Access Control Design Patterns
Only the owner (using OpenZeppelin's Ownable contract) can fund the contract without showing up as a donor (fundContract), only the owner can set the address of the game (setGameAddress),
and only the owner can change the reward (changeReward).


# Security Measures
### Proper Use of Require
Used throughout the code instead of if-else statements.
### Use Modifiers Only for Validation
A modifier was made so that only the game can set the variable (setKittens function) required to redeem the reward so that nobody just sets it using the console.
modifier onlyGame() {
    require(msg.sender == gameAddress, "Only game can call");
    _;
}
### Checks-Effects-Interactions
Several checks are made throughout the functions. For example, the setKittens function checks whether the user has 60 kittens or not. If they do, then they can't add more. This is done
to prevent hoarding by using a bot, or someone's younger brother!
Another examples are the checks in the rewardUser function that checks whether the user has enough kittens for a reward or not, whether they have collected enoughr ewards for the
day or not, and whether the contract has enough funds or not.


# Important Links and Addresses

## Contract Addres
0xEDDe9fc8ca8668046f9EAf9b64FDc94620518E26
https://sepolia.scrollscan.com/address/0xEDDe9fc8ca8668046f9EAf9b64FDc94620518E26

## dApp link
https://blokkat-arabicblockchain-developer.vercel.app/

## Game link
https://rpg-game-sepolia-cats.vercel.app/


# How To Run Tests
In order to run the 10 test functions in the GameContract.t.sol file, just run "forge test" after installing Foundry in /foundry-smartContract.
In order to install Foundry follow this guide: https://book.getfoundry.sh/introduction/installation/


# How To Run The Program
To run the dApp using the files, open a terminal in /react-reown and run "npm install" to retrieve the required dependencies and then run "npm run dev" to run the web application.
To run the game using the files, open a terminal in /sepolia-cats-game and run "npm http-server".
However, it's recommended to just use the links mentioned above.