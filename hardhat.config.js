require("@nomicfoundation/hardhat-toolbox");

const PRIVATE_KEY =
  "7dde404846262b29dc58f48c82db4e5230872748246a6f89ae34d2c2acaeaf07";
const BSC_TEST_API_URL = "https://bsc-testnet-rpc.publicnode.com";

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  defaultNetwork: "bsc_test",
  solidity: "0.8.24",
  networks: {
    hardhat: {},
    bsc_test: {
      url: BSC_TEST_API_URL,
      accounts: [`0x${PRIVATE_KEY}`],
    },
  },
  etherscan: {
    apiKey: "HZWKC8M1FP57IFNITKXW5DIG2B9QHZUY25",
  },
};
