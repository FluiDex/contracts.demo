// SPDX-License-Identifier: MIT OR Apache-2.0

pragma solidity ^0.8.0;

library Bytes {

    function shiftAndReverseBits8(uint8 val, uint8 offset) internal pure returns (uint256 ret) {
        uint16 effectLen = offset < 248 ? 8 : 256 - offset;
        for(uint16 i = 0; i < effectLen; i++){
            if (val & 1 == 1){
                ret += (1 << (255-i-offset));
            }
            val >>=1;
        }
    }

    function shiftAndReverseBits16(uint16 val, uint8 offset) internal pure returns (uint256 ret) {
        uint16 effectLen = offset < 240 ? 16 : 256 - offset;
        for(uint16 i = 0; i < effectLen; i++){
            if (val & 1 == 1){
                ret += (1 << (255-i-offset));
            }
            val >>=1;
        }
    }

    function shiftAndReverseBits32(uint32 val, uint8 offset) internal pure returns (uint256 ret) {
        uint16 effectLen = offset < 224 ? 32 : 256 - offset;
        for(uint16 i = 0; i < effectLen; i++){
            if (val & 1 == 1){
                ret += (1 << (255-i-offset));
            }
            val >>=1;
        }
    }

    function shiftAndReverseBits64(uint64 val, uint8 offset) internal pure returns (uint256 ret) {
        uint16 effectLen = offset < 192 ? 64 : 256 - offset;
        for(uint16 i = 0; i < effectLen; i++){
            if (val & 1 == 1){
                ret += (1 << (255-i-offset));
            }
            val >>=1;
        }
    }

    function shiftAndReverseBits128(uint128 val, uint8 offset) internal pure returns (uint256 ret) {
        uint16 effectLen = offset < 128 ? 128 : 256 - offset;
        for(uint16 i = 0; i < effectLen; i++){
            if (val & 1 == 1){
                ret += (1 << (255-i-offset));
            }
            val >>=1;
        }
    }

    function shiftAndReverseBits(uint256 val, uint8 offset) internal pure returns (uint256 ret) {
        for(uint16 i = 0; i < 256 - offset; i++){
            if (val & 1 == 1){
                ret += (1 << (255-i-offset));
            }
            val >>=1;
        }
    }

    //see https://ethereum.stackexchange.com/questions/83626/how-to-reverse-byte-order-in-uint256-or-bytes32
    function swapBytes(uint256 input) internal pure returns (uint256 v) {
        v = input;

        // swap bytes
        v = ((v & 0xFF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00) >> 8) |
            ((v & 0x00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF) << 8);

        // swap 2-byte long pairs
        v = ((v & 0xFFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000) >> 16) |
            ((v & 0x0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF) << 16);

        // swap 4-byte long pairs
        v = ((v & 0xFFFFFFFF00000000FFFFFFFF00000000FFFFFFFF00000000FFFFFFFF00000000) >> 32) |
            ((v & 0x00000000FFFFFFFF00000000FFFFFFFF00000000FFFFFFFF00000000FFFFFFFF) << 32);

        // swap 8-byte long pairs
        v = ((v & 0xFFFFFFFFFFFFFFFF0000000000000000FFFFFFFFFFFFFFFF0000000000000000) >> 64) |
            ((v & 0x0000000000000000FFFFFFFFFFFFFFFF0000000000000000FFFFFFFFFFFFFFFF) << 64);

        // swap 16-byte long pairs
        v = (v >> 128) | (v << 128);
    }

    // See comment at the top of this file for explanation of how this function works.
    // NOTE: theoretically possible overflow of (_start + 0x2)
    function bytesToUInt16(bytes memory _bytes, uint256 _start) internal pure returns (uint16 r) {
        uint256 offset = _start + 0x2;
        require(_bytes.length >= offset, "T");
        assembly {
            r := mload(add(_bytes, offset))
        }
    }

    // NOTE: theoretically possible overflow of (_offset + 2)
    function readUInt16(bytes memory _data, uint256 _offset) internal pure returns (uint256 newOffset, uint16 r) {
        newOffset = _offset + 2;
        r = bytesToUInt16(_data, _offset);
    }
}