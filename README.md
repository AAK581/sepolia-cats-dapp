# Flow Cats: A Gamified Flow Faucet!




# About this project

## Project Description
Flow Cats is a gamified testnet FLOW faucet made on the testnet FLOW blockchain.
Users can claim testnet FLOWs by collecting kittens in the game which can be synced online using the Teleporter
in-game item.
Upon collecting at least 15 kittens, a user can claim a reward from the dApp, with a maximum of 4 rewards per day.
The game was made using RPG Maker MZ, the dApp was made using a React app using Reown Appkit and Wagmi, and the smart contract was tested
using Foundry.

## Directory Structure

### /react-reown:
Contains the front-end React app (src/App.jsx, src/App.css, package.json, etc.).

### /foundry-smartContract:
Contains the smart contract, the test file, and other important files related to Foundry as well as OpenZeppelin's Ownable contract.

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
There is also another check that validates whether the user has any FLOW or not. If they don't then they wouldn't be able to claim the reward
as they wouldn't be able to pay for gas. This is solved by the game dripping at most 0.01 FLOW per day to the user in case they have 0 FLOW.


# Important Links and Addresses

## Contract Address
### Game Contract
0x292Fe1de6ce0ca4917fB6163ECb4C00b395D5804      
https://evm-testnet.flowscan.io/address/0x292Fe1de6ce0ca4917fB6163ECb4C00b395D5804     

### NFT Contract      
0x335777beD22AdA837E46D28AE83ba697eDD09d62      
https://evm-testnet.flowscan.io/address/0x335777beD22AdA837E46D28AE83ba697eDD09d62

## dApp link
https://flow-cats-dapp.vercel.app/

## Game link
https://flow-cats-rpg-game.vercel.app/


# How To Run Tests
In order to run the test functions in the GameContract.t.sol file, just run "forge test" after installing Foundry in /foundry-smartContract.
In order to install Foundry, follow this guide: https://book.getfoundry.sh/introduction/installation/


# How To Run The Program
To run the dApp using the files, open a terminal in /react-reown and run "npm install" to retrieve the required dependencies and then run "npm run dev" to run the web application.
To run the game using the files, go to https://github.com/AAK581/flow-Cats-rpg-game and download the files, then open a terminal and run "npm http-server".
However, it's recommended to just use the links mentioned above.

# Demo

