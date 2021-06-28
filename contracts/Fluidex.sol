// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

contract FluidexDemo {
   enum BlockState {
      Empty,
      Submitted,
      Verified
   }

   uint256 GENESIS_ROOT;
   mapping(uint256 => uint256) public state_roots;   
   mapping(uint256 => BlockState) public block_states;

   constructor(uint256 _genesis_root) public {
      GENESIS_ROOT = _genesis_root;
   }

   function get_block_state_by_block_id(uint256 block_id) public returns (BlockState) {
      return block_states[block_id];
   }
}
