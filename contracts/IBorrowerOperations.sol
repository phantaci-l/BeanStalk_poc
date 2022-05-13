// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

interface IBorrowerOperations{
    function openTrove(
        uint256 _maxFee,
        uint256 _LUSDAmount,
        uint256 _ETHAmount,
        address _upperHint,
        address _lowerHint,
        address _frontEndTag
    ) external;
}