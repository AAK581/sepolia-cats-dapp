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

    function test_fundContract() public {
        vm.deal(owner, 5 ether);
        gameContractTest.fundContract{value: 2 ether}();
        assertEq(address(gameContractTest).balance, 2 ether);
    }

    function test_setKittens() public {
        vm.prank(game);
        gameContractTest.setKittens(user, 60);
        uint256 testKittens = gameContractTest.userKittens(user);
        assertEq(testKittens, 60);
    }

    function test_SetKittensMax() public {
        vm.startPrank(game);
        vm.expectRevert("You can't set more than 60 kittens");
        gameContractTest.setKittens(user, 61);
        vm.stopPrank;
    }

    function test_getKittens() public{
        vm.prank(user);
        uint256 test_get = gameContractTest.getKittens();
        assertEq(test_get, gameContractTest.userKittens(user));
    }

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

    function test_KittensUpdatedEvent() public {
        vm.expectEmit(true, true, false, false, address(gameContractTest)); 
        emit GameContract.KittensUpdated(user, 40);
        vm.prank(game);
        gameContractTest.setKittens(user, 40);
    }

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

    function test_changeReward() public {
        uint256 newReward = 30 ether;
        gameContractTest.changeReward(newReward);
        
        assertEq(gameContractTest.REWARD(), 30 ether);
    }

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

function test_donate() public {
    vm.deal(user, 1 ether);
    vm.prank(user);
    (bool success, ) = address(gameContractTest).call{value: 0.3 ether}("");
    assertTrue(success);
    assertEq(address(gameContractTest).balance, 0.3 ether);
}
}