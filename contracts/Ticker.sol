// SPDX-License-Identifier: MIT OR Apache-2.0

pragma solidity ^0.8.0;

contract Ticker {

    uint256 ticktock;

    constructor() {
        ticktock = 0;
    }

    function tick() public {
        ticktock = block.number;
    }
}
