// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "./PlonkCore.sol";

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

   function get_block_state_by_block_id(uint256 _block_id) public returns (BlockState) {
      return block_states[_block_id];
   }

   function submit_block(
      uint256 _block_id,
      uint256[] memory _public_inputs,
      uint256[] memory _serialized_proof
   ) public returns (bool) {
      // _public_inputs[0] is previous_state_root
      // _public_inputs[1] is new_state_root
      require(_public_inputs.length >= 2);
      if (_block_id == 0) {
         assert(_public_inputs[0] == GENESIS_ROOT);
      } else {
         assert(_public_inputs[0] == state_roots[_block_id-1]);         
      }

      // TODO: state transistion & proof verification

      return true;
   }
}
