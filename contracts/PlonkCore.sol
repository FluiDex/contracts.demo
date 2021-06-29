// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

// TODO: implement this
// TODO: migrate as interface
contract PlonkCore {
    function verify_serialized_proof(
        uint256[] memory _public_inputs, 
        uint256[] memory _serialized_proof
    ) public view returns (bool) {
        return true;
    }  
}
