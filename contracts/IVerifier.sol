// SPDX-License-Identifier: MIT OR Apache-2.0

pragma solidity ^0.8.0;

interface IVerifier {
    function verify_serialized_proof(
        uint256[] memory public_inputs,
        uint256[] memory serialized_proof
    ) external view returns (bool);
}
