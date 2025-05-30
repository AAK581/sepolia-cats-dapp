const ethers = require("ethers");

export default async function handler(req, res) {
  try {
    console.log("setKittens API: Checking GAME_PRIVATE_KEY", { hasKey: !!process.env.GAME_PRIVATE_KEY });
    if (!process.env.GAME_PRIVATE_KEY) {
      console.error("setKittens API: GAME_PRIVATE_KEY missing");
      return res.status(500).json({ error: "Missing GAME_PRIVATE_KEY" });
    }
    let wallet;
    try {
      wallet = new ethers.Wallet(process.env.GAME_PRIVATE_KEY);
      console.log("setKittens API: Wallet address:", wallet.address);
    } catch (error) {
      console.error("setKittens API: Invalid GAME_PRIVATE_KEY", error.message);
      return res.status(500).json({ error: "Invalid GAME_PRIVATE_KEY format" });
    }
    if (req.method !== "POST") {
      console.error("setKittens API: Method not allowed", req.method);
      return res.status(405).json({ error: "Method not allowed" });
    }
    const { kittens, userAddress } = req.body;
    if (!Number.isInteger(kittens) || kittens > 60 || kittens < 0 || !ethers.isAddress(userAddress)) {
      console.error("setKittens API: Invalid input", { kittens, userAddress });
      return res.status(400).json({ error: "Invalid input" });
    }
    const provider = new ethers.JsonRpcProvider("https://sepolia-rpc.scroll.io");
    const signer = wallet.connect(provider);
    const balance = await provider.getBalance(wallet.address);
    console.log("setKittens API: Balance:", ethers.formatEther(balance), "ETH");
    const contract = new ethers.Contract(
      "0xA45a75B3523334bf4017b0BB9D76d4E06661fba3",
      [
  {
    "type": "constructor",
    "inputs": [],
    "stateMutability": "nonpayable"
  },
  {
    "type": "receive",
    "stateMutability": "payable"   
  },
  {
    "type": "function",
    "name": "KITTENS_REQUIRED",    
    "inputs": [],
    "outputs": [
      {
        "name": "",
        "type": "uint256",
        "internalType": "uint256"
      }
    ],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "REWARD",
    "inputs": [],
    "outputs": [
      {
        "name": "",
        "type": "uint256",
        "internalType": "uint256"
      }
    ],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "changeReward",
    "inputs": [
      {
        "name": "newReward",
        "type": "uint256",
        "internalType": "uint256"
      }
    ],
    "outputs": [],
    "stateMutability": "nonpayable"
  },
  {
    "type": "function",
    "name": "dailyRewards",
    "inputs": [
      {
        "name": "",
        "type": "address",
        "internalType": "address"
      }
    ],
    "outputs": [
      {
        "name": "",
        "type": "uint256",
        "internalType": "uint256"
      }
    ],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "fundContract",
    "inputs": [],
    "outputs": [],
    "stateMutability": "payable"
  },
  {
    "type": "function",
    "name": "gameAddress",
    "inputs": [],
    "outputs": [
      {
        "name": "",
        "type": "address",
        "internalType": "address"
      }
    ],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "getKittens",
    "inputs": [],
    "outputs": [
      {
        "name": "",
        "type": "uint256",
        "internalType": "uint256"
      }
    ],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "getTotalKittens",
    "inputs": [],
    "outputs": [
      {
        "name": "",
        "type": "uint256",
        "internalType": "uint256"
      }
    ],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "lastClaimDay",
    "inputs": [
      {
        "name": "",
        "type": "address",
        "internalType": "address"
      }
    ],
    "outputs": [
      {
        "name": "",
        "type": "uint256",
        "internalType": "uint256"
      }
    ],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "owner",
    "inputs": [],
    "outputs": [
      {
        "name": "",
        "type": "address",
        "internalType": "address"
      }
    ],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "renounceOwnership",
    "inputs": [],
    "outputs": [],
    "stateMutability": "nonpayable"
  },
  {
    "type": "function",
    "name": "rewardUser",
    "inputs": [],
    "outputs": [],
    "stateMutability": "nonpayable"
  },
  {
    "type": "function",
    "name": "setGameAddress",
    "inputs": [
      {
        "name": "_gameAddress",
        "type": "address",
        "internalType": "address"
      }
    ],
    "outputs": [],
    "stateMutability": "nonpayable"
  },
  {
    "type": "function",
    "name": "setKittens",
    "inputs": [
      {
        "name": "userAddress",
        "type": "address",
        "internalType": "address"
      },
      {
        "name": "_value",
        "type": "uint256",
        "internalType": "uint256"
      }
    ],
    "outputs": [],
    "stateMutability": "nonpayable"
  },
  {
    "type": "function",
    "name": "totalKittens",
    "inputs": [],
    "outputs": [
      {
        "name": "",
        "type": "uint256",
        "internalType": "uint256"
      }
    ],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "transferOwnership",
    "inputs": [
      {
        "name": "newOwner",
        "type": "address",
        "internalType": "address"
      }
    ],
    "outputs": [],
    "stateMutability": "nonpayable"
  },
  {
    "type": "function",
    "name": "userKittens",
    "inputs": [
      {
        "name": "",
        "type": "address",
        "internalType": "address"
      }
    ],
    "outputs": [
      {
        "name": "",
        "type": "uint256",
        "internalType": "uint256"
      }
    ],
    "stateMutability": "view"
  },
  {
    "type": "event",
    "name": "DonationReceived",
    "inputs": [
      {
        "name": "user",
        "type": "address",
        "indexed": true,
        "internalType": "address"
      },
      {
        "name": "amount",
        "type": "uint256",
        "indexed": false,
        "internalType": "uint256"
      }
    ],
    "anonymous": false
  },
  {
    "type": "event",
    "name": "KittensUpdated",
    "inputs": [
      {
        "name": "user",
        "type": "address",
        "indexed": true,
        "internalType": "address"
      },
      {
        "name": "newValue",
        "type": "uint256",
        "indexed": false,
        "internalType": "uint256"
      }
    ],
    "anonymous": false
  },
  {
    "type": "event",
    "name": "OwnershipTransferred",
    "inputs": [
      {
        "name": "previousOwner",
        "type": "address",
        "indexed": true,
        "internalType": "address"
      },
      {
        "name": "newOwner",
        "type": "address",
        "indexed": true,
        "internalType": "address"
      }
    ],
    "anonymous": false
  },
  {
    "type": "event",
    "name": "UserRewarded",
    "inputs": [
      {
        "name": "user",
        "type": "address",
        "indexed": true,
        "internalType": "address"
      },
      {
        "name": "amount",
        "type": "uint256",
        "indexed": false,
        "internalType": "uint256"
      }
    ],
    "anonymous": false
  },
  {
    "type": "error",
    "name": "OwnableInvalidOwner",
    "inputs": [
      {
        "name": "owner",
        "type": "address",
        "internalType": "address"
      }
    ]
  },
  {
    "type": "error",
    "name": "OwnableUnauthorizedAccount",
    "inputs": [
      {
        "name": "account",
        "type": "address",
        "internalType": "address"
      }
    ]
  }
],
      signer
    );
    console.log("setKittens API: Sending tx", { kittens, userAddress });
    const tx = await contract.setKittens(userAddress, kittens, { gasLimit: 300000 });
    const receipt = await tx.wait();
    console.log("setKittens API: Success", { txHash: tx.hash });
    return res.status(200).json({ txHash: tx.hash });
  } catch (error) {
    console.error("setKittens API Error:", error.message, error.stack);
    return res.status(500).json({ error: error.message });
  }
}