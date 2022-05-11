// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

interface IDiamondCut {
    enum FacetCutAction {Add, Replace, Remove}

    struct FacetCut {
        address facetAddress;
        FacetCutAction action;
        bytes4[] functionSelectors;
    }

    /// @notice Add/replace/remove any number of functions and optionally execute
    ///         a function with delegatecall
    /// @param _diamondCut Contains the facet addresses and function selectors
    /// @param _init The address of the contract or facet to execute _calldata
    /// @param _calldata A function call, including function selector and arguments
    ///                  _calldata is executed with delegatecall on _init
    function diamondCut(
        FacetCut[] calldata _diamondCut,
        address _init,
        bytes calldata _calldata
    ) external;

    event DiamondCut(FacetCut[] _diamondCut, address _init, bytes _calldata);
}

interface GovernanceFacet{
    function vote(uint32 bip) external;
    function emergencyCommit(uint32 bip) external;
    function commit(uint32 bip) external;
    function propose(
        IDiamondCut.FacetCut[] calldata _diamondCut,
        address _init,
        bytes calldata _calldata,
        uint8 _pauseOrUnpause
    )external;
    function bip(uint32 bipId) external view returns (address,uint32,uint32,bool,int256,uint128,uint256,uint256);
    function numberOfBips() external view returns (uint32);
    function activeBips() external view returns (uint32[] memory);
    function voted(address account, uint32 bipId) external view returns (bool);
}

interface IBeanStalk{
    // struct FacetCut {
    //     address facetAddress;
    //     uint8 action;
    //     bytes4[] functionSelectors;
    // }
    // struct Claim {
    //     uint32[] beanWithdrawals;
    //     uint32[] lpWithdrawals;
    //     uint256[] plots;
    //     bool claimEth;
    //     bool convertLP;
    //     uint256 minBeanAmount;
    //     uint256 minEthAmount;
    //     bool toWallet;
    // }

    function deposit(address token, uint256 amount) external;

    // function activeBips() external view returns (uint32[] memory);

    function depositBeans(uint256 amount) external;

    // function season() external view returns (uint32);

    // function withdrawBeans(uint32[] calldata crates, uint256[] calldata amounts)
    //     external;

    // function claimAndWithdrawBeans(
    //     uint32[] calldata crates,
    //     uint256[] calldata amounts,
    //     Claim calldata claim
    // ) external;

    // function propose(
    //     FacetCut[] calldata _diamondCut,
    //     address _init,
    //     bytes calldata _calldata,
    //     uint8 _pauseOrUnpause
    // ) external;

    function vote(uint32 bip) external;

    function emergencyCommit(uint32 bip) external;

    // function balanceOfRoots(address account) external view returns (uint256);
}

interface IGovernanceFacet {
    function activeBips() external view returns (uint32[] memory);

    function bip(uint32 bipId) external view returns (IGovernanceFacetStorage.Bip memory);

    function bipDiamondCut(uint32 bipId)
    external
    view
    returns (IGovernanceFacetStorage.DiamondCut memory);

    function bipFacetCuts(uint32 bipId)
    external
    view
    returns (IDiamondCut.FacetCut[] memory);

    function commit(uint32 bip) external;

    function emergencyCommit(uint32 bip) external;

    function numberOfBips() external view returns (uint32);

    function ownerPause() external;

    function ownerUnpause() external;

    function pauseOrUnpause(uint32 bip) external;

    function propose(
        IDiamondCut.FacetCut[] memory _diamondCut,
        address _init,
        bytes memory _calldata,
        uint8 _pauseOrUnpause
    ) external;

    function rootsFor(uint32 bipId) external view returns (uint256);

    function unvote(uint32 bip) external;

    function unvoteAll(uint32[] memory bip_list) external;

    function vote(uint32 bip) external;

    function voteAll(uint32[] memory bip_list) external;

    function voteUnvoteAll(uint32[] memory bip_list) external;

    function voted(address account, uint32 bipId) external view returns (bool);
}

interface IGovernanceFacetStorage {
    struct Bip {
        address proposer;
        uint32 start;
        uint32 period;
        bool executed;
        int256 pauseOrUnpause;
        uint128 timestamp;
        uint256 roots;
        uint256 endTotalRoots;
    }

    struct DiamondCut {
        IDiamondCut.FacetCut[] diamondCut;
        address initAddress;
        bytes initData;
    }
}
