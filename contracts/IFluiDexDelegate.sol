// SPDX-License-Identifier: MIT OR Apache-2.0

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IFluiDexDelegate {
    /**
     * @notice request to add a new ERC20 token
     * @param tokenAddr the ERC20 token address
     * @return the new ERC20 token tokenId
     */
    function addToken(address tokenAddr) external returns (uint16);

    /**
     * @param to the L2 address (bjjPubkey) of the deposit target.
     */
    function depositETH(bytes32 to) external payable;

    /**
     * @param to the L2 address (bjjPubkey) of the deposit target.
     * @param amount the deposit amount.
     */
    function depositERC20(
        IERC20 token,
        bytes32 to,
        uint128 amount
    ) external;

    /**
     * @notice request to submit a new l2 block
     * @param _block_id the l2 block id
     * @param _public_inputs the public inputs of this block
     * @param _serialized_proof the serialized proof of this block
     * @param _public_data the serialized tx data inside this block (data availability)
     * @return true if the block was accepted
     */
    function submitBlock(
        uint256 _block_id,
        uint256[] memory _public_inputs,
        uint256[] memory _serialized_proof,
        bytes memory _public_data
    ) external returns (bool);
}
