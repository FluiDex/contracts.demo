// SPDX-License-Identifier: MIT OR Apache-2.0

pragma solidity ^0.8.0;

interface Events {
    event NewToken(address submitter, address tokenAddr, uint16 tokenId);
    event RegisterUser(address ethAddr, uint16 userId, bytes32 bjjPubkey);
    event Deposit(uint16 tokenId, bytes32 to, uint256 amount);
}
