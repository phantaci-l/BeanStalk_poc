require("@nomiclabs/hardhat-waffle");

// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  solidity: {
    version: "0.8.0",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200
      }
    }
  },
  networks: {
    local: {
      url: 'http://127.0.0.1:8545',
    },
    hardhat: {
      forking: {
        url: "https://eth-mainnet.alchemyapi.io/v2/axyTMpOt1jPOBxtPvD0TcHCbpwwT60U-",        //beanstalk
        blockNumber: 14839152
      }
    },
    // hardhat: {
    //   forking: {
    //     url: "https://bsc-mainnet.nodereal.io/v1/1005333b090f46aa9edb747e3fa5235a",             //fortress
    //     blockNumber: 17634617
    //   }
    // }
    // hardhat: {
    //   forking: {
    //     url: "https://bsc-mainnet.nodereal.io/v1/95e1e8119e3e472281baaf7e53a5288f",             //fortress
    //     blockNumber: 17832802
    //   }
    // }
  },
  paths: {
    sources: "./contracts",
    tests: "./test",
    cache: "./cache",
    artifacts: "./artifacts",
    scripts: "./scripts",
  },
  mocha: {
    timeout: 20000
  }
};
