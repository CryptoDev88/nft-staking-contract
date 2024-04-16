import { ethers } from "hardhat";
import { config } from "./config";

async function main() {
  const [deployer] = await ethers.getSigners();

  // // here it will dpeloy
  console.log("----- Start ------");
  // const token = await ethers.getContractFactory("contracts/SAPE.sol:SAPE");
  // const contract = await token.deploy();
  // console.log("SAPE: ", contract.target);

  // await verifySAPEToken();

  // const token = await ethers.getContractFactory("contracts/APE.sol:APE");
  // const contract = await token.deploy();
  // console.log("APE: ", contract.target);

  // await verifyAPEToken();

  // const NFTStaking = await ethers.getContractFactory(
  //   "contracts/NFTStaking.sol:NFTStaking"
  // );
  // const contract = await NFTStaking.deploy(config.SAPEToken, config.APEToken);
  // console.log("NFTStaking: ", contract.target);

  await verifyStaking();

  console.log("----- End ------");
}

async function verifySAPEToken() {
  await hre.run("verify:verify", {
    address: config.SAPEToken,
    contract: "contracts/SAPE.sol:SAPE",
  });
}

async function verifyAPEToken() {
  await hre.run("verify:verify", {
    address: config.APEToken,
    contract: "contracts/APE.sol:APE",
  });
}

async function verifyStaking() {
  await hre.run("verify:verify", {
    address: config.NFTStaking,
    constructorArguments: [config.SAPEToken, config.APEToken],
    contract: "contracts/NFTStaking.sol:NFTStaking",
  });
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
