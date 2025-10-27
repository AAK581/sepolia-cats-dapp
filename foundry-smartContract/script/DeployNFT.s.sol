// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/MilestoneNFT.sol";

contract DeployNFT is Script {
    function run() external {
        uint256 pk = vm.envUint("PK");
        vm.startBroadcast(pk);

        MilestoneNFT nft = new MilestoneNFT(
            "Flow Cats Milestone",
            "FCM",
            "https://gray-improved-whitefish-326.mypinata.cloud/ipfs/bafkreihvvoruwp2hfaunndote5nh2umohdf77ucps2wqka7ikaxcg7lvre"
        );

        console.log("NFT DEPLOYED TO:", address(nft));

        vm.stopBroadcast();
    }
}