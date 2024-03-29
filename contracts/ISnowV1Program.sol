// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.14;

interface ISnowV1Program {
    function name() external view returns (string memory);

    function run(uint256[64] calldata canvas, uint8 lastUpdatedIndex)
        external
        returns (uint8 index, uint256 value);
}