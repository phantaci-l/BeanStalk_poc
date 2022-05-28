// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;


import "./IERC20.sol";
import "./console.sol";
import "./IUniswapV2pair.sol";
import "./IUniswapV2Factory.sol";


interface Ifeeto{
    function removeLiqidity(address token0, address token1, uint amount) external;
    function marketBuyLuaWithETH(address[] calldata path, uint amount, uint deadline) external;
    function marketBuyLuaWithToken(address[] calldata path, uint amount, uint deadline) external;
    function convert(address token0, address token1) external;
}

contract lp_convert{

    address public constant feeto = 0xe11a87506FE17F9Fb5EEcaB14E85Af27A7C10e19;
    address public constant LUA_V1 = 0xd6bE3b9780572f0215aFB3e4d15751955503CeBE;
    address public constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address public constant factory = 0x0388C1E0f210AbAe597B7DE712B9510C6C36C857;
    address public constant LUA_V1_WETH = 0x6bA68Ca9285B9e62fDfa9E6D9A2d82C3F54f14aa;

}