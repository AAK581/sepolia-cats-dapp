// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/MilestoneNFT.sol";

contract DeployNFT is Script {
    function run() external {
        uint256 pk = vm.envUint("PK");
        vm.startBroadcast(pk);

        string memory baseURI = "https://gray-improved-whitefish-326.mypinata.cloud/ipfs/bafybeifzsqfm6emnz4pcow62oalmcajyv3e3biz7iro5ljtizm2f3rfzza/";

        MilestoneNFT nft = new MilestoneNFT(
            "Flow Cats Milestone",
            "FCM",
            baseURI
        );

        console.log("NFT DEPLOYED TO:", address(nft));
        console.log("BASE URI SET TO:", baseURI);

        vm.stopBroadcast();
    }
}