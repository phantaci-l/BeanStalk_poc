// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

interface FToken{

}

interface IUnitroller{
    function enterMarkets(address[] calldata fTokens) external returns (uint[] memory);
    function getAllMarkets() external view returns (FToken[] memory);
}