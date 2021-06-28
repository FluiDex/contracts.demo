// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

contract FluidexDemo {
   enum BlockState {
      Empty,
      Submitted,
      Verified
   }

   mapping(uint256 => BlockState) public block_states;
}
