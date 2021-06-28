// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

contract FluidexDemo {
}



// // 实际上没必要存这些 map， demo 版先这么写

//     map state_roots; // block_id → state_root

//     map block_states; // block_id → {empty / submitted / verified ) 

 

// pub fn submit_block(block_id, state_root_before, state_root_after, proof) {

// if block_id == 0 {

//     assert(state_root_before == GENESIS_ROOT);

// } else {

//    assert(state_root_before == this.state_roots[block_id - 1])

// }

// if proof is not null {

//     public_data = [state_root_before, state_root_after];

//    assert(zkproof(public_data, proof));

//    this.block_states[block_id] = VERIFIED;

// } else {

//    // we don’t have CPU resource now. it is a demo version anyway

//    this.block_states[block_id] = SUBMITTED;

// }

// this.state_roots[block_id] = state_root_after;

// }

 

// pub fn get_state_root_by_block_id(block_id) {

// return this.state_roots[block_id];

// }

// pub fn get_block_state_by_block_id(block_id) {

//    return this.block_states[block_id];

// }