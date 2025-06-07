//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test, console} from "forge-std/Test.sol";
import {GameContract} from "../src/GameContract.sol";

contract GameContractTest is Test {
    GameContract public gameContractTest;
    address user = makeAddr("user");
    address owner;
    address game = makeAddr("game");

    function setUp() public {
        owner = address(this);
        gameContractTest = new GameContract();
        //vm.deal(address(gameContractTest), 5 ether);
        vm.deal(owner, 5 ether);
        vm.deal(user, 5 ether);
        vm.deal(game, 5 ether);
        gameContractTest.setGameAddress(game);
    }

    // This allows the owner (a contract in this case) to receive funds from the withdrawFunds function
    receive() external payable {}

    // This tests the fundContract function
    function test_fundContract() public {
        vm.deal(owner, 5 ether);
        gameContractTest.fundContract{value: 2 ether}();
        assertEq(address(gameContractTest).balance, 2 ether);
    }

    // This tests the setting kittens funtion
    function test_setKittens() public {
        vm.prank(game);
        gameContractTest.setKittens(user, 60);
        uint256 testKittens = gameContractTest.userKittens(user);
        assertEq(testKittens, 60);
    }

    // This tries to set more than the limit of 60 kittens
    function test_SetKittensMax() public {
        vm.startPrank(game);
        vm.expectRevert("Cannot add more than 60 kittens at once");
        gameContractTest.setKittens(user, 61);
        vm.stopPrank;
    }

    // This tries to return the amount of kittens
    function test_getKittens() public{
        vm.prank(user);
        uint256 test_get = gameContractTest.getKittens();
        assertEq(test_get, gameContractTest.userKittens(user));
    }

    // This tries to reward the user
    function test_rewardUser() public {
        vm.deal(owner, 5 ether);
        gameContractTest.fundContract{value: 5 ether}();

        vm.startPrank(game);
        vm.deal(user, 1 ether);
        gameContractTest.setKittens(user, 60);
        vm.startPrank(user);
        gameContractTest.rewardUser();
        vm.stopPrank();
        assertEq(user.balance, 1.2 ether);
    }

    // This checks if an event emits when a user sets their kittens
    function test_KittensUpdatedEvent() public {
        vm.expectEmit(true, true, false, false, address(gameContractTest)); 
        emit GameContract.KittensUpdated(user, 40);
        vm.prank(game);
        gameContractTest.setKittens(user, 40);
    }

    // This checks if an event emits when a user claims a reward
    function test_UserRewardedEvent() public {
        vm.deal(owner, 5 ether);
        gameContractTest.fundContract{value: 5 ether}();

        vm.expectEmit(true, true, false, false, address(gameContractTest));
        emit GameContract.KittensUpdated(user, 0.05 ether);
        vm.startPrank(game);
        gameContractTest.setKittens(user, 20);
        vm.startPrank(user);
        gameContractTest.rewardUser();
        vm.stopPrank();
    }

    // This tries to change the reward to 30 ETH
    function test_changeReward() public {
        uint256 newReward = 30 ether;
        gameContractTest.changeReward(newReward);
        
        assertEq(gameContractTest.REWARD(), 30 ether);
    }

    // This tests what would happen if a user tries to claim more than the allowed daily limit (4 rewards)
    function test_rewardUser_dailyLimit() public {
        vm.deal(owner, 5 ether);
        gameContractTest.fundContract{value: 5 ether}();

        vm.startPrank(game);
        vm.deal(user, 1 ether);
        gameContractTest.setKittens(user, 45);
        vm.startPrank(user);
        gameContractTest.rewardUser();
        assertEq(user.balance, 1.15 ether);
        assertEq(gameContractTest.getKittens(), 0);

        // Same day, try again
        vm.startPrank(game);
        gameContractTest.setKittens(user, 60);
        vm.expectRevert("Daily reward limit reached");
        vm.startPrank(user);
        gameContractTest.rewardUser();
        vm.stopPrank();
    }

    // This tests donations and the event emmitted afterwards
    function test_donate() public {
        vm.deal(user, 1 ether);
        vm.prank(user);
        vm.expectEmit(true, true, false, false, address(gameContractTest));
        emit GameContract.DonationReceived(user, 0.3 ether);
        (bool success, ) = address(gameContractTest).call{value: 0.3 ether}("");
        assertTrue(success);
        assertEq(address(gameContractTest).balance, 0.3 ether);
    }

    // This test drains the contract's funds and directs them to the owner
    function test_withdrawFunds() public {
        vm.deal(address(gameContractTest), 5 ether);
        vm.prank(owner);
        gameContractTest.withdrawFunds();
        assertEq(address(gameContractTest).balance, 0);
        assertEq(address(owner).balance, 10 ether);
    }
}