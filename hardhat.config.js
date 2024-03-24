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
    
    // mainnet: {
    //   url: "https://mainnet.infura.io/v3/ea70518c68764a27808b0ea30a18e496",
    //   accounts: ["acf3342a7baa1c909844794bee0b45a0fec7a31c0ffa8f9a9f854d48221ac7b6"],
    //   gasPrice: 27000000000
    // },
    // ropsten: {
    //   url: "https://ropsten.infura.io/v3/9e4c4b48907f4beba4ca0f3cc9d50ea2",
    //   accounts: ["nada"]
    // },
    // rinkeby: {
    //   url: "https://rinkeby.infura.io/v3/9e4c4b48907f4beba4ca0f3cc9d50ea2",
    //   accounts: [""]
    // },
    goerli: {
      url: "https://polygon-mumbai.infura.io/v3/2ab3958c803c4a549d630c65159fcc76",
      accounts: ["4821b5e72daec351b8c19a2e067bac0851db9bfc29c56e311640bc26c1ee7215"]
    }
    // sepolia: {
    //   url: "https://sepolia.infura.io/v3/ea70518c68764a27808b0ea30a18e496",
    //   accounts: ["4821b5e72daec351b8c19a2e067bac0851db9bfc29c56e311640bc26c1ee7215"]
    // }
    // polygon: {
    //   url: "https://polygon-mainnet.infura.io/v3/9eb0dc5722cf4909b4c13a2c2b16bcd6",
    //   accounts: [""]
    // }
    
  },
  etherscan: {
    // Your API key for Etherscan
    // Obtain one at https://etherscan.io/
    apiKey: "RTA2TKY3ZHMT9NSBPIDMFI9HI7AFM5RBY6"
  }
};
