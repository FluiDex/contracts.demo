// SPDX-License-Identifier: MIT OR Apache-2.0

pragma solidity ^0.8.0;

import "./Operations.sol";

/// @title Unittest contract for libraries
contract TestLibs {
    function testBitsOp8(uint8 val, uint8 offset)
        public
        pure
        returns (uint256)
    {
        return Bytes.shiftAndReverseBits8(val, offset);
    }

    function testBitsOp32(uint32 val, uint8 offset)
        public
        pure
        returns (uint256)
    {
        return Bytes.shiftAndReverseBits32(val, offset);
    }

    function testBitsOp256(uint256 val, uint8 offset)
        public
        pure
        returns (uint256)
    {
        return Bytes.shiftAndReverseBits(val, offset);
    }

    function testWriteRegistryPubdata(uint32 accId, bytes32 l2key)
        public
        pure
        returns (bytes20)
    {
        Operations.Registry memory op = Operations.Registry({
            accountId: accId,
            l2key: l2key
        });

        return Operations.writeRegistryPubdataForPriorityQueue(op);
    }

    function testWriteDepositPubdata(
        uint32 accId,
        uint16 tokenId,
        uint128 amount
    ) public pure returns (bytes20) {
        Operations.Deposit memory op = Operations.Deposit({
            accountId: accId,
            tokenId: tokenId,
            amount: amount
        });

        return Operations.writeDepositPubdataForPriorityQueue(op);
    }
}
