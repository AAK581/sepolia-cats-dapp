// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;
import "forge-std/Script.sol";
import "../src/GameContract.sol";
contract SetGameAddress is Script {
    function run() external {
        address contractAddress = 0xEDDe9fc8ca8668046f9EAf9b64FDc94620518E26;
        address gameAddress = 0xB6B9B1a2E68F4ac770D5850735D055D6a2207374;

        vm.startBroadcast();
        GameContract contractInstance = GameContract(payable(contractAddress));
        contractInstance.setGameAddress(gameAddress);
        vm.stopBroadcast();
    }
}