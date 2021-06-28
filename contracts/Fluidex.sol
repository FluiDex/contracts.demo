// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

contract FluidexDemo {
   enum BlockState {
      Empty,
      Submitted,
      Verified
   }

   mapping(uint256 => BlockState) public block_states;

   function get_block_state_by_block_id(uint256 block_id) public returns (BlockState) {
      return block_states[block_id];
   }
}
