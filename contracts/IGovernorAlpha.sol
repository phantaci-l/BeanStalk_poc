// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

interface IGovernorAlpha {
    enum ProposalState {
        Pending,
        Active,
        Canceled,
        Defeated,
        Succeeded,
        Queued,
        Expired,
        Executed
    }
    function execute(uint256 proposalId) external payable;
    function state(uint proposalId) external view returns (ProposalState);
    function queue(uint proposalId) external;
    function castVote(uint proposalId, bool support) external;
    function propose(address[] memory targets, uint[] memory values, string[] memory signatures, bytes[] memory calldatas, string memory description) external returns (uint);

}

interface IChain{
    function submit(
        uint32 _dataTimestamp,
        bytes32 _root,
        bytes32[] memory _keys,
        uint256[] memory _values,
        uint8[] memory _v,
        bytes32[] memory _r,
        bytes32[] memory _s
    ) external;
}