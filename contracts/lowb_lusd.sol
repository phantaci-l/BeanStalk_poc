// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;


import "./IERC20.sol";
import "./console.sol";
import "./IUniswapV2pair.sol";


interface ILUSD{
    function getLowbNeedToMint(uint lusdAmount) external view returns (uint);
    function getLowbReturnAmount(uint lusdAmount) external view returns (uint);
    function getLowbAmountImm(uint lusdAmount) external view returns (uint);
    function getLowbAmountRef(uint lusdAmount) external view returns (uint);
    function mint(uint112 amount) external;
    function burn(uint112 amount) external;
}
