import logo from './logo.svg';
import { useState } from 'react';
import { ethers } from 'ethers';
import Greeter from './artifacts/contracts/Greeter.sol/Greeter.json';
import Loot from './artifacts/contracts/Loot.sol/Loot.json';
import LootBattles from './artifacts/contracts/LootBattles.sol/LootBattles.json';
import xxxLoot from './artifacts/contracts/xxxLoot.sol/xxxLoot.json';
import MsgNFT from './artifacts/contracts/MessageNFT.sol/MessageMeNFT.json';
import testContractabi from './artifacts/contracts/testContract.sol/TestContract.json';
import './App.css';

const lootAddress = "0x5FbDB2315678afecb367f032d93F642f64180aa3"
const lootBattlesAddress = "0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0"
const lootComponents = "0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512"
const xxxLootAddress = "0x2279B7A0a67DB372996a5FaB50D91eAA73d2eBe6"

const vaultBoxContract = "0xab0b0dD7e4EaB0F9e31a539074a03f1C1Be80879"

const msgAddress = "0x9A676e781A523b5d0C0e43731313A708CB607508";

const testContract = "0xdF7ab1007773c89EB458c933025Bf3610e432027";

function App() {
  

  const [greeting, setGreetingValue] = useState('')

  async function requestAccount() {
    await window.ethereum.request({method: 'eth_requestAccounts' })
  }

  async function CheckIDs() {
    if (typeof window.ethereum !== 'undefined') {

      // const provider = new ethers.providers.Web3Provider(window.ethereum)
      // const contract = new ethers.Contract(vaultBoxContract, vault.abi, provider)
      // const trans = await contract.ownerOf(1)
      // console.log("owner of " + 1 + trans)
      // await requestAccount()
      // const provider = new ethers.providers.Web3Provider(window.ethereum)
      // const signer = provider.getSigner()
      // const contract = new ethers.Contract(vaultBoxContract, vault.abi, signer)

    }
  }

  async function ClaimNFT() {
    if (typeof window.ethereum !== 'undefined') {
      await requestAccount()
      const provider = new ethers.providers.Web3Provider(window.ethereum)
      const signer = provider.getSigner()
      const contract = new ethers.Contract(testContract, testContractabi.abi, signer)
      const transaction = await contract.mint()
      // await transaction.wait()
      // const data = await contract.tokenURI(1001)
      // console.log('data: ', transaction)
      // try {
      //   const data = await contract
      //   console.log('data: ', data)
      // } catch (err) {
      //   console.log("Error: ", err)
      // }
    }
  }

  async function getMSGTokenURI() {
    if (typeof window.ethereum !== 'undefined') {
      const provider = new ethers.providers.Web3Provider(window.ethereum)
      const contract = new ethers.Contract(msgAddress, MsgNFT.abi, provider)
      try {
        const data = await contract.tokenURI(1)
        console.log('data: ', data)
      } catch (err) {
        console.log("Error: ", err)
      }
    } 
  }

  async function ClaimOwnerxxxNFT() {
    if (typeof window.ethereum !== 'undefined') {
      await requestAccount()
      const provider = new ethers.providers.Web3Provider(window.ethereum)
      const signer = provider.getSigner()
      const contract = new ethers.Contract(xxxLootAddress, xxxLoot.abi, signer)
      const transaction = await contract.ownerClaim(7778)
      // await transaction.wait()
      // const data = await contract.tokenURI(1001)
      // console.log('data: ', transaction)
      // try {
      //   const data = await contract
      //   console.log('data: ', data)
      // } catch (err) {
      //   console.log("Error: ", err)
      // }
    }
  }

  async function ClaimxxxNFT() {
    if (typeof window.ethereum !== 'undefined') {
      await requestAccount()
      const provider = new ethers.providers.Web3Provider(window.ethereum)
      const signer = provider.getSigner()
      const contract = new ethers.Contract(xxxLootAddress, xxxLoot.abi, signer)
      const transaction = await contract.claim(1004)
      // await transaction.wait()
      // const data = await contract.tokenURI(1001)
      // console.log('data: ', transaction)
      // try {
      //   const data = await contract
      //   console.log('data: ', data)
      // } catch (err) {
      //   console.log("Error: ", err)
      // }
    }
  }

  async function SeexxxNFT() {
    if (typeof window.ethereum !== 'undefined') {
      const provider = new ethers.providers.Web3Provider(window.ethereum)
      const contract = new ethers.Contract(xxxLootAddress, xxxLoot.abi, provider)
      try {
        const data = await contract.tokenURI(1002)
        console.log('data: ', data)
      } catch (err) {
        console.log("Error: ", err)
      }
    }   
  }

  async function TestLootBattles() {
    if (typeof window.ethereum !== 'undefined') {
      await requestAccount()
      // const provider = new ethers.providers.Web3Provider(window.ethereum)
      // const contract = new ethers.Contract(lootBattlesAddress, LootBattles.abi, provider)
      let utils = ethers.utils;
      let filter = {
        address: lootBattlesAddress,
        topics: [
          utils.id("Battled(uint256,uint256,uint256)")
        ]
      }

      const provider = new ethers.providers.Web3Provider(window.ethereum)
      provider.on(filter, (attacker, defender, winner) => {
        console.log(attacker, defender, winner)
      })
      const signer = provider.getSigner()
      const contract = new ethers.Contract(lootBattlesAddress, LootBattles.abi, signer)
      const transaction = await contract.Battle(1002, 1004)
      await transaction.wait()
      console.log('data: ', transaction.value)
      // try {
      //   const data = await contract.Battle(1001, 1002)
      //   console.log('data: ', data)
      // } catch (err) {
      //   console.log("Error: ", err)
      // }
    }
  }

  async function SeeBattleHistory() {
    if (typeof window.ethereum !== 'undefined') {
      const provider = new ethers.providers.Web3Provider(window.ethereum)
      const contract = new ethers.Contract(lootBattlesAddress, LootBattles.abi, provider)
      try {
        const data = await contract.GetBattleStories()
        console.log('data: ', data)
      } catch (err) {
        console.log("Error: ", err)
      }
    }   
  }

  async function CheckOwnerOfXXX() {
    if (typeof window.ethereum !== 'undefined') {
          const provider = new ethers.providers.Web3Provider(window.ethereum)
          const contract = new ethers.Contract(xxxLootAddress, xxxLoot.abi, provider)
          try {
            const data = await contract.ownerOf(7778)
            console.log('data: ', data)
          } catch (err) {
            console.log("Error: ", err)
          }
    }
  }

  async function SeeWins() {
    if (typeof window.ethereum !== 'undefined') {
          const provider = new ethers.providers.Web3Provider(window.ethereum)
          const contract = new ethers.Contract(lootBattlesAddress, LootBattles.abi, provider)
          try {
            const data = await contract.GetWins()
            console.log('data: ', data)
          } catch (err) {
            console.log("Error: ", err)
          }
    }
  }

  async function SeeLosses() {
    if (typeof window.ethereum !== 'undefined') {
      const provider = new ethers.providers.Web3Provider(window.ethereum)
      const contract = new ethers.Contract(lootBattlesAddress, LootBattles.abi, provider)
      try {
        const data = await contract.GetLosses()
        console.log('data: ', data)
      } catch (err) {
        console.log("Error: ", err)
      }
    }
  }

  // async function fetchGreeting() {
  //   if (typeof window.ethereum !== 'undefined') {
  //     const provider = new ethers.providers.Web3Provider(window.ethereum)
  //     const contract = new ethers.Contract(greeterAddress, Greeter.abi, provider)
  //     try {
  //       const data = await contract.greet()
  //       console.log('data: ', data)
  //     } catch (err) {
  //       console.log("Error: ", err)
  //     }
  //   }
  // }

  // async function setGreeting() {
  //   if (!greeting) return
  //   if (typeof window.ethereum !== 'undefined') {
  //     await requestAccount()
  //     const provider = new ethers.providers.Web3Provider(window.ethereum)
  //     const signer = provider.getSigner()
  //     const contract = new ethers.Contract(greeterAddress, Greeter.abi, signer)
  //     const transaction = await contract.setGreeting(greeting)
  //     setGreetingValue('')
  //     await transaction.wait()
  //     fetchGreeting()
  //   }
  // }

  async function setMsg() {
    if (!greeting) return
    if (typeof window.ethereum !== 'undefined') {
      await requestAccount()
      const provider = new ethers.providers.Web3Provider(window.ethereum)
      const signer = provider.getSigner()
      const contract = new ethers.Contract(msgAddress, MsgNFT.abi, signer)
      const transaction = await contract.writeFree('0x9013C8A1f0073269DaEc5e9dfcDd16AB66ff96c7', greeting)
      setGreetingValue('')
      await transaction.wait()
    }
  }
  return (
    <div className="App">
      <header className="App-header">
        <button onClick={ClaimNFT}>Claim NFT</button>
        <button onClick={ClaimxxxNFT}>Claim xxxNFT</button>
        <button onClick={requestAccount}>Connect Web3</button>
        <button onClick={TestLootBattles}>Test Loot Battles</button>
        <button onClick={SeeWins}>See Wins</button>
        <button onClick={CheckIDs}>Check Vault IDS</button>
        <button onClick={SeeLosses}>See Loses</button>
        <button onClick={SeeBattleHistory}>Stories</button>
        <button onClick={getMSGTokenURI}>GetMsgDataTokenURI</button>
        <button onClick={SeexxxNFT}>see xxxLoot</button>
        <button onClick={ClaimOwnerxxxNFT}>Calim owner xxxLoot</button>
        <button onClick={ClaimOwnerxxxNFT}>Calim owner xxxLoot</button>
        <button onClick={setMsg}>Set MSG</button>
        <input
          onChange={e => setGreetingValue(e.target.value)}
          placeholder="Set Greeting"
          value={greeting}
        />
      </header>
    </div>
  );
}

export default App;
