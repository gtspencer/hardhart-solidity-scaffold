import logo from './logo.svg';
import { Connection,PublicKey } from "@solana/web3.js";
import { useState, useEffect } from 'react';
import { ethers } from 'ethers';
import abi from './abi'
import './App.css';

const uniswapBaseAddress = "0x33128a8fC17869897dcE68Ed026d694621f6FDfD"
const wethAddress = "0x4200000000000000000000000000000000000006"

const RAYDIUM_PUBLIC_KEY = ('675kPX9MHTjS2zt1qfr1NYHuzeLXfQM9H24wFSUt1Mp8');
const raydium = new PublicKey(RAYDIUM_PUBLIC_KEY);
const connection = new Connection('https://api.mainnet-beta.solana.com',{
    wsEndpoint: 'wss://api.mainnet-beta.solana.com'

});

let processedSignatures = new Set();

function App() {
  const [greeting, setGreetingValue] = useState('');
  const [rows, setRows] = useState([]);

  async function listenForSolana(connection,raydium){
    console.log('Monitoring logs...',raydium.toString());
    connection.onLogs(raydium,({logs,err,signature})=>{
        if(err) return;
        if(logs && logs.some(log=> log.includes('initialize2') && !processedSignatures.has(signature))){
            processedSignatures.add(signature);
            console.log('Signature for Initialize2:',signature);
            fetchRaydiumAccounts(signature,connection);
        }
    }, "finalized");
}

  async function fetchRaydiumAccounts(signature,connection){
    const txId = signature;
    const tx = await connection.getParsedTransaction(txId, {maxSupportedTransactionVersion:0, commitment:"confirmed"});
    const accounts = tx?.transaction?.message?.instructions.find(ix=>ix.programId.toBase58()===RAYDIUM_PUBLIC_KEY).accounts;

    if(!accounts){
        console.log('No accounts found');
        return;
    }
    const tokenAIndex=8;
    const tokenBIndex=9;

    const tokeAAccount = accounts[tokenAIndex];
    const tokenBAccount = accounts[tokenBIndex];
    const displayData=[
        {Token:'Token A',account:tokeAAccount},
        {Token:'Token B',account:tokenBAccount},
    ];
    console.log("New Raydium  Liquidity Pool Created Found");
    console.log(generateExplorerUrl(txId));
    console.table(displayData);
    // await sleep(2000);
}

function generateExplorerUrl(txId){
    return `https://solscan.io/tx/${txId}?cluster=mainnet`;
}

  useEffect(() => {
    async function listenFactory() {
      if (typeof window.ethereum !== 'undefined') {
        // await listenForSolana(connection, raydium);

        await window.ethereum.request({ method: 'eth_requestAccounts' })
        const provider = new ethers.providers.Web3Provider(window.ethereum)
        const factory = new ethers.Contract(uniswapBaseAddress, abi, provider)
        console.log('starting to listen')
        factory.on('PoolCreated', (token0, token1, fee, tickSpacing, pool) => {
          console.log(`Pool created with ${token0} & ${token1} at ${pool}`)
          setRows(prevRows => [...prevRows, { token0, token1, pool }]);
        })
      }
    }

  

    listenFactory();

    // Cleanup function to remove event listener
    return () => {
      // Remove event listener here if needed
    };
  }, []); // Empty dependency array ensures this effect runs only once

  return (
    <div className="App">
      <header className="App-header">
        <div className="scrollable-window">
          <table>
            <thead>
              <tr>
                <th>Token 0</th>
                <th>Token 1</th>
                <th>Pool Address</th>
              </tr>
            </thead>
            <tbody>
              {rows.map((row, index) => (
                <tr key={index}>
                  <td>{row.token0}</td>
                  <td>{row.token1}</td>
                  <td>{row.pool}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
        {/* <input
          onChange={e => setGreetingValue(e.target.value)}
          placeholder="Set Greeting"
          value={greeting}
        /> */}
      </header>
    </div>
  );
}

export default App;
