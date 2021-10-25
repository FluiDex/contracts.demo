// SPDX-License-Identifier: MIT OR Apache-2.0

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./IFluiDex.sol";
import "./IFluiDexDelegate.sol";

contract FluiDexDelegate is AccessControl, IFluiDexDelegate, ReentrancyGuard {

    IFluiDex target;
    event TargetChange(IFluiDex prev, IFluiDex now);

    constructor(IFluiDex _target) {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        target = _target;
    }

    /**
     */
    function setTarget(IFluiDex _target)
        public
        nonReentrant
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        IFluiDex prev = target;
        target = _target;
        emit TargetChange(prev, _target);
    }

    /**
     * @notice request to add a new ERC20 token
     * @param tokenAddr the ERC20 token address
     * @return the new ERC20 token tokenId
     */
    function addToken(address tokenAddr) 
        external 
        override
        returns (uint16) 
    {
        return target.addToken(msg.sender, tokenAddr);
    }

    /**
     * @param to the L2 address (bjjPubkey) of the deposit target.
     */
    function depositETH(bytes32 to) external payable override {
        target.depositETH{value: msg.value}(msg.sender, to);
    }

    /**
     * @param to the L2 address (bjjPubkey) of the deposit target.
     * @param amount the deposit amount.
     */
    function depositERC20(
        IERC20 token,
        bytes32 to,
        uint128 amount
    ) external override {
        target.depositERC20(msg.sender, token, to, amount);
    }

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
    ) external override returns (bool) {
        return target.submitBlock(_block_id, _public_inputs, _serialized_proof);
    }
}
