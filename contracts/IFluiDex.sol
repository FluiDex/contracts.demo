// SPDX-License-Identifier: MIT OR Apache-2.0

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IFluiDex {
    enum BlockState {
        Empty,
        Committed,
        Verified
    }

    struct UserInfo {
        address ethAddr;
        bytes32 bjjPubkey;
    }

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
     * @param amount the deposit amount.
     */
    function depositERC20(IERC20 token, uint256 amount)
        external
        returns (uint16 tokenId, uint256 realAmount);

    function getBlockStateByBlockId(uint256 _block_id)
        external
        returns (BlockState);

    /**
     * @notice request to submit a new l2 block
     * @param _block_id the l2 block id
     * @param _public_inputs the public inputs of this block
     * @param _serialized_proof the serialized proof of this block
     * @return true if the block was accepted
     */
    function submitBlock(
        uint256 _block_id,
        uint256[] memory _public_inputs,
        uint256[] memory _serialized_proof
    ) external returns (bool);

    /**
     * @dev this won't verify the pubkey
     * @param ethAddr the L1 address
     * @param bjjPubkey the L2 address (bjjPubkey)
     */
    function registerUser(address ethAddr, bytes32 bjjPubkey)
        external
        returns (uint16 userId);

    /**
     * @param tokenId tokenId
     * @return tokenAddr
     */
    function getTokenAddr(uint16 tokenId) external view returns (address);

    /**
     * @param tokenAddr tokenAddr
     * @return tokenId
     */
    function getTokenId(address tokenAddr) external view returns (uint16);

    /**
     * @param userId userId
     * @return UserInfo
     */
    function getUserInfo(uint16 userId) external view returns (UserInfo memory);

    /**
     * @param bjjPubkey user's pubkey
     * @return userId, returns 0 if not exist
     */
    function getUserId(bytes32 bjjPubkey) external view returns (uint16);
}
