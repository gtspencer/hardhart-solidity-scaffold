require("@nomiclabs/hardhat-waffle");
require("@nomiclabs/hardhat-etherscan");
// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  solidity: "0.8.14",
  paths: {
    artifacts: './src/artifacts',
  },
  networks: {
    hardhat: {
      chainId: 1337
    },
    
    mainnet: {
      url: "https://mainnet.infura.io/v3/9e4c4b48907f4beba4ca0f3cc9d50ea2",
      accounts: [""],
      gasPrice: 40000000000
    },
    // ropsten: {
    //   url: "https://ropsten.infura.io/v3/9e4c4b48907f4beba4ca0f3cc9d50ea2",
    //   accounts: ["nada"]
    // },
    rinkeby: {
      url: "https://rinkeby.infura.io/v3/9e4c4b48907f4beba4ca0f3cc9d50ea2",
      accounts: [""]
    },
    goerli: {
      url: "https://goerli.infura.io/v3/9e4c4b48907f4beba4ca0f3cc9d50ea2",
      accounts: [""]
    },
    polygon: {
      url: "https://polygon-mainnet.infura.io/v3/9eb0dc5722cf4909b4c13a2c2b16bcd6",
      accounts: [""]
    }
    
  },
  etherscan: {
    // Your API key for Etherscan
    // Obtain one at https://etherscan.io/
    apiKey: ""
  }
};
