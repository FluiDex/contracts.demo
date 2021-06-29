// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "./PlonkCore.sol";

contract FluidexDemo is PlonkCore {
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

   function getBlockStateByBlockId(uint256 _block_id) public returns (BlockState) {
      return block_states[_block_id];
   }

   function submitBlock(
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

      if (_serialized_proof.length != 0) {
         // TODO: hash inputs and then pass into verifier
         assert(verifySerializedProof(_public_inputs, _serialized_proof));
         block_states[_block_id] = BlockState.Verified;
      } else {
         // mark a block as Submitted (Committed) directly, because we may
         // temporarily run out of proving resource.
         // note: Committing a block without a rollback/revert mechanism should
         // only happen in demo version!
         block_states[_block_id] = BlockState.Submitted;
      }
      state_roots[_block_id] = _public_inputs[1];

      return true;
   }
}
