# Sepolia Cats: A Gamified Sepolia Ethereum Faucet!
![image](https://github.com/user-attachments/assets/c373921a-775c-46e2-8c43-768e343ce523)
![image](https://github.com/user-attachments/assets/56af50e6-967b-4eb7-8dd8-4543809f3565)
![image](https://github.com/user-attachments/assets/7f965537-36e0-438d-be96-eb397ec7f7b8)
![image](https://github.com/user-attachments/assets/f137fbc0-4ccc-4c50-b334-8eb29e460d7e)
![image](https://github.com/user-attachments/assets/5695fa99-31dd-4c9a-9b8d-8ae7a0bc8834)



# About this project

## Project Description
Sepolia Cats is a gamified Sepolia Ethereum faucet made on top of the Scroll L2 network.
Users can claim Scroll Sepolia or Sepolia ETH by collecting kittens in the kgame which can be synced online using the Teleporter
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

## Contract Address
### Scroll Sepolia
0xA45a75B3523334bf4017b0BB9D76d4E06661fba3        
https://sepolia.scrollscan.com/address/0xa45a75b3523334bf4017b0bb9d76d4e06661fba3        

### Sepolia
0xa9C4cd6C657f5110C6966c78962D47c24D27BD57        
https://sepolia.etherscan.io/address/0xa9C4cd6C657f5110C6966c78962D47c24D27BD57        

## dApp link
https://blokkat-arabicblockchain-developer.vercel.app/

## Game link
https://rpg-game-sepolia-cats.vercel.app/


# How To Run Tests
In order to run the 11 test functions in the GameContract.t.sol file, just run "forge test" after installing Foundry in /foundry-smartContract.
In order to install Foundry, follow this guide: https://book.getfoundry.sh/introduction/installation/


# How To Run The Program
To run the dApp using the files, open a terminal in /react-reown and run "npm install" to retrieve the required dependencies and then run "npm run dev" to run the web application.
To run the game using the files, open a terminal in /sepolia-cats-game and run "npm http-server".
However, it's recommended to just use the links mentioned above.

# Demo
https://drive.google.com/file/d/1JIVIAH64-9euZEi7hedDiXJMlxMTK9NS/view?usp=drive_link
