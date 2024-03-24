import React, { useEffect, useState } from 'react';
import { useLocation } from 'react-router-dom';

const DetailsPage = () => {
  const location = useLocation();
  const { search } = location;
  const params = new URLSearchParams(search);

  const [rowData, setRowData] = useState([]);
  const wethAddress = "0x4200000000000000000000000000000000000006";
  let poolAddress = params.get("pool")
  
  function getQuoteToken(token0, token1) {
    if (token0 == wethAddress) {
      return token1 
    }

    return token0
  }

  let tokenAddress = getQuoteToken(params.get("token0"), params.get("token1"))

  useEffect(() => {
    GetDexInfo()
    const data = [];
    for (let [key, value] of params) {
      data.push({ key, value });
    }
    setRowData(data);
  }, [search]);

  function GetDexInfo() {
    // const link = `https://api.dexscreener.io/latest/dex/pairs/base/${poolAddress}`
    const link = `https://api.dexscreener.io/latest/dex/pairs/base/${poolAddress}`
    fetch(link)
        .then(response => response.json())
        .then(data => {
            console.log(data)
        })
    .catch(error => {
      console.error(error);
    });
  }

  function GetDexScreenerUrl(lPool) {
    const dexScreener = `https://dexscreener.com/base/${lPool}`
    return dexScreener
  }

  function GetBaseScanContractUrl() {
    const url = `https://basescan.org/address/${tokenAddress}`
    return url
  }

  const openDexScreener = () => {
    window.open(GetDexScreenerUrl(poolAddress))
  };

  const openBaseScanUrl = () => {
    window.open(GetBaseScanContractUrl())
  };

  return (
    <div>
      <h2>Details Page</h2>
      <ul>
        {rowData.map((item, index) => (
          <li key={index}>
            <strong>{item.key}:</strong> {item.value}
          </li>
        ))}
      </ul>
      <button onClick={openDexScreener}>Dex Screener</button> {/* Button to add test values */}
      <button onClick={openBaseScanUrl}>Base Scan Contract</button> {/* Button to add test values */}
    </div>
  );
};

export default DetailsPage;
