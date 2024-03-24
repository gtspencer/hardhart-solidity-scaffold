import logo from './logo.svg';
import { Connection, PublicKey } from "@solana/web3.js";
import { useState, useEffect, useRef } from 'react'; // Import useRef
import { ethers } from 'ethers';
import abi from './abi';
import './AppStyles.css';
import './App.css';
import sound from './im-about-to-cuhh.mp3'

const uniswapBaseAddress = "0x33128a8fC17869897dcE68Ed026d694621f6FDfD";
const wethAddress = "0x4200000000000000000000000000000000000006";

function HomePage() {
  const [rows, setRows] = useState([]);
  const audio = new Audio(sound)
  let txnNumber = 0

  async function listenFactory() {
    if (typeof window.ethereum !== 'undefined') {
      await window.ethereum.request({ method: 'eth_requestAccounts' })
      const provider = new ethers.providers.Web3Provider(window.ethereum)
      const factory = new ethers.Contract(uniswapBaseAddress, abi, provider)
      console.log('starting to listen')
      factory.on('PoolCreated', (token0, token1, fee, tickSpacing, pool) => {
        newToken(token0, token1, fee, tickSpacing, pool)
      })
    }
  }

  async function newToken(token0, token1, fee, tickSpacing, pool) {
    txnNumber++
    playAudio()
    console.log(`Pool created (${txnNumber}) with ${token0} & ${token1} at ${pool}`)
    let row = { id: txnNumber, token0, token1, pool, time: GetTime(), name: "..." }
    await setRows(prevRows => [row, ...prevRows]);
    // TODO rows is not set at this point...
    GetTokenData(getQuoteToken(token0, token1), txnNumber)
  }

  function getQuoteToken(row) {
    getQuoteToken(row.token0, row.token1)
    return
  }

  function getQuoteToken(token0, token1) {
    if (token0 == wethAddress) {
      return token1 
    }

    return token0
  }

  async function GetTokenData(tokenAddress, txnId, tries = 1) {
    if (tries > 5) {return}
    const url = `https://api.dexscreener.io/latest/dex/tokens/${tokenAddress}`
    console.log(`try ${tries} to get token data for ${tokenAddress} from ${url}. . . `)
    let found = false
    
    await fetch(url)
      .then(response => response.json())
      .then(data => {
          if (data.pairs) {
            found = true;

            let pair = data.pairs[0]
            if (!pair) {return}
            let token = pair.quoteToken
            if (token.address == wethAddress) {
              token = pair.baseToken
            }
            console.log("searching in " + rows.length)
            for (let r of rows) {
              console.log(r.id)
              if (r.id == txnId) {
                console.log("found name " + token.name)
                r.name = token.name
                setRows(rows)
              }
            }
          }
          console.log(data)
    })
    .catch(error => {
      console.error(error);
    });

    if (!found) {
      console.log(`fail boo hoo trying again in 5 seconds`)
      await new Promise(r => setTimeout(r, 5000));
      GetTokenData(tokenAddress, ++tries)
    }
  }

  // async function GetTokenData(tokenAddress, tries = 1) {
  //   if (tries > 5) {return}
  //   console.log(`try ${tries} to get token data for ${tokenAddress}. . . `)
  //   let found = false
  //   const url = `https://api.basescan.org/api
  //   ?module=token
  //   &action=tokeninfo
  //   &contractaddress=${tokenAddress}
  //   &apikey=P2C9DEYINFVP1NE5C6R4IG8SDSEV4MHPS9`
  //   await fetch(url)
  //     .then(response => response.json())
  //     .then(data => {
  //         if (data.pairs) {
  //           found = true;
  //         }
  //         console.log(data)
  //   })
  //   .catch(error => {
  //     console.error(error);
  //   });

  //   if (!found) {
  //     console.log(`fail boo hoo trying again in 5 seconds`)
  //     await new Promise(r => setTimeout(r, 5000));
  //     GetTokenData(tokenAddress, ++tries)
  //   }
  // }



  
  const playAudio = () => {
    audio.currentTime = 0
    audio.play()
  }

  function GetTime() {
    let time = new Date();
    const timeString = `${time.getHours()}:${time.getMinutes()}:${time.getSeconds()}`
    return timeString
  }

  // Function to add test values to the table
  const addTestValues = () => {
    // setRows(prevRows => [
    //   { token0: '0x8F4359D1C2166452b5e7a02742D6fe9ca5448FDe', token1: '0x8F4359D1C2166452b5e7a02742D6fe9ca5448FDe', pool: '0x8F4359D1C2166452b5e7a02742D6fe9ca5448FDe', time: GetTime() },
    //   { token0: '0x8F4359D1C2166452b5e7a02742D6fe9ca5448FDe', token1: 'Test Token 4', pool: 'Test Pool Address 2', time: GetTime() },
    //   // Add more test values as needed
    //   ...prevRows
    // ]);

    newToken("0xE1338B1D731A89454a2ADf0c302b2A4B1C6a02DA", wethAddress, 0, 0, "0x67591338a1061E05a0C74cB3fb5F200597336cf0")

    // GetTokenData("0xE1338B1D731A89454a2ADf0c302b2A4B1C6a02DA")
  };

  const openNewTab = (rowData) => {
    // Serialize rowData into a query string
    const queryString = new URLSearchParams(rowData).toString();
    // Open a new tab with the URL containing the query string
    window.open(`/details?${queryString}`, '_blank');
  };

  useEffect(() => {
    listenFactory();
    // Cleanup function to remove event listener
    return () => {
      // Remove event listener here if needed
    };
  }, []); // Empty dependency array ensures this effect runs only once


  return (
    <div className="App">
      <header className="App-header">
        <div className="container">
          <div className="scrollable-window"> {/* Assign ref to the table */}
            <table>
              <thead>
                <tr>
                  <th>Id</th>
                  <th>Time</th>
                  <th>Name</th>
                  <th>Token 0</th>
                  <th>Token 1</th>
                  <th>Pool Address</th>
                </tr>
              </thead>
              <tbody>
                {rows.map((row, index) => (
                  <tr key={index} onClick={() => openNewTab(row)}>
                    <td>{row.id}</td>
                    <td>{row.time}</td>
                    <td>{row.name}</td>
                    <td>{row.token0}</td>
                    <td>{row.token1}</td>
                    <td>{row.pool}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
        <button onClick={addTestValues}>Add Test Values</button> {/* Button to add test values */}
        <button onClick={playAudio}>Play</button>
      </header>
    </div>
  );
}

export default HomePage;
