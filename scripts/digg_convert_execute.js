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


    // const factory = "0xC0AEe478e3658e2610c5F7A4A2E1777cE9e4f2Ac";
    const WETH = "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2";
    const WBTC = "0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599";

    const WBTC_DIGG = "0x9a13867048e01c663ce8Ce2fE0cDAE69Ff9F35E3";
    const WBTC_WETH = "0xCEfF51756c56CeFFCA006cD410B03FFC46dd3a58";
    const DIGG = "0x798D1bE841a82a273720CE31c822C61a67a601C3";
    const DIGG_WETH = "0xf41E354EB138B328d56957B36B7F814826708724";

    const SUSHI_Router = "0xd9e1cE17f2641f24aE83637ab66a2cca9C378B9F";
    const sushi_maker = "0xE11fc0B43ab98Eb91e9836129d1ee7c3Bc95df50";
  
  
    const erc20_abi = ["function balanceOf(address account) external view returns (uint256)", "function approve(address spender, uint256 amount) external returns (bool)", "function transferFrom(address from, address to, uint256 amount) external returns (bool)", "function transfer(address to, uint value) external returns (bool)"];
    const router_abi = ["function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline) external payable returns (uint[] memory amounts)", "function addLiquidityETH(address token, uint amountTokenDesired, uint amountTokenMin, uint amountETHMin, address to, uint deadline) external payable returns (uint amountToken, uint amountETH, uint liquidity)", "function swapExactTokensForTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external returns (uint[] memory amounts)", "function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline) external returns (uint[] memory amounts)", "function removeLiquidityETH(address token,uint liquidity,uint amountTokenMin,uint amountETHMin,address to,uint deadline) external returns (uint amountToken, uint amountETH)", "function swapExactETHForTokensSupportingFeeOnTransferTokens(uint amountOutMin,address[] calldata path,address to,uint deadline) external payable"];
    const uni_pair_abi = ["function getReserves() public view returns (uint112 _reserve0, uint112 _reserve1, uint32 _blockTimestampLast)"];
    const maker_abi = ["function convert(address token0, address token1) external"];
    const factory_abi = ["function feeTo() external view returns (address)", "function swapFee() external view returns (uint)", "function withdrawFee() external view returns (uint)", "function withdrawFeeTo() external view returns (address)", "function migrator() external view returns (address)", "function getPair(address tokenA, address tokenB) external view returns (address pair)"];


    const DIGG_WETH_token = new ethers.Contract(DIGG_WETH, erc20_abi, signer);
    const DIGG_token = new ethers.Contract(DIGG, erc20_abi, signer);
    const WBTC_token = new ethers.Contract(WBTC, erc20_abi, signer);
    const WETH_token = new ethers.Contract(WETH, erc20_abi, signer);

    const WBTC_WETH_token = new ethers.Contract(WBTC_WETH, erc20_abi, signer);
    const WBTC_DIGG_token = new ethers.Contract(WBTC_DIGG, erc20_abi, signer);

    // const sushi_factory = new ethers.Contract(factory, factory_abi, signer);
    const Router = new ethers.Contract(SUSHI_Router, router_abi, signer);
    const maker = new ethers.Contract(sushi_maker, maker_abi, signer);
    const WBTC_DIGG_pair = new ethers.Contract(WBTC_DIGG, uni_pair_abi, signer);
    const DIGG_WETH_pair = new ethers.Contract(DIGG_WETH, uni_pair_abi, signer);
    // const slp1_pair = new ethers.Contract(slp1, uni_pair_abi, signer);

    // We get the contract to deploy after 1 day...
    // await ethers.provider.send("evm_increaseTime", [1.5 * 24 * 60 * 60]);
    
    //1xxxxx swapexactETHfortokens to get DIGG
    await Router.swapExactETHForTokens(0, [WETH, WBTC, DIGG], signer.address, Date.now(), {value : ethers.utils.parseEther('0.001')});
    var DIGG_amount = await DIGG_token.balanceOf(signer.address);
    console.log("1xxxxx my account has got DIGG_amount: ", DIGG_amount, await ethers.provider.getBlockNumber());

    //2xxxxx addliquidity to get DIGG_WETH lp token
    await DIGG_token.approve(SUSHI_Router, BigInt(99999999999999999999999999999));
    await Router.addLiquidityETH(DIGG, BigInt(17211), BigInt(17211), BigInt(1000000000000000), signer.address, Date.now(), {value : ethers.utils.parseEther('0.001')});
    // console.log("2xxxxx ------------DIGG_WETH pair reserve: ", await DIGG_WETH_pair.getReserves());
    var DIGG_WETH_token_amount = await DIGG_WETH_token.balanceOf(signer.address);
    var maker_amount = await WBTC_DIGG_token.balanceOf(sushi_maker);
    console.log("2xxxxx my account has got DIGG_WETH_lp_amount: ", DIGG_WETH_token_amount, maker_amount);

    //3xxxxx convert maker
    await maker.convert(DIGG, WBTC);
    // console.log("3xxxxx ------------DIGG_WETH pair reserve: ", await DIGG_WETH_pair.getReserves());
    // console.log("3xxxxx WBTC_DIGG pair reserve: ", await WBTC_DIGG_pair.getReserves());

    //4xxxxx swap slp1
    await Router.swapExactETHForTokensSupportingFeeOnTransferTokens(0, [WETH, DIGG, WBTC, WETH], signer.address, Date.now(), {value : ethers.utils.parseEther('0.001')});
    // var MKR_WETH_lp_amount_remain = await MKR_WETH_token.balanceOf(signer.address);
    console.log("4xxxxx my account has got WETH: ", await WETH_token.balanceOf(signer.address));


}
  
  // We recommend this pattern to be able to use async/await everywhere
  // and properly handle errors.
  main()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error(error);
      process.exit(1);
    });