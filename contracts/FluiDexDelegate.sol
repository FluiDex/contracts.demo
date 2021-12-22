// SPDX-License-Identifier: MIT OR Apache-2.0

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./Events.sol";
import "./IFluiDex.sol";
import "./IFluiDexDelegate.sol";

contract FluiDexDelegate is
    AccessControl,
    Events,
    IFluiDexDelegate,
    ReentrancyGuard
{
    using SafeERC20 for IERC20;

    bytes32 public constant TOKEN_ADMIN_ROLE = keccak256("TOKEN_ADMIN_ROLE");

    /// use 0 representing ETH in tokenId
    uint16 constant ETH_ID = 0;

    IFluiDex target;
    event TargetChange(IFluiDex prev, IFluiDex now);

    constructor(IFluiDex _target) {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setRoleAdmin(TOKEN_ADMIN_ROLE, DEFAULT_ADMIN_ROLE);
        grantRole(TOKEN_ADMIN_ROLE, msg.sender);
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
     * @return tokenId the new ERC20 token tokenId
     */
    function addToken(address tokenAddr)
        external
        override
        onlyRole(TOKEN_ADMIN_ROLE)
        returns (uint16 tokenId)
    {
        tokenId = target.addToken(tokenAddr);
        emit NewToken(msg.sender, tokenAddr, tokenId);
    }

    /**
     * @param to the L2 address (bjjPubkey) of the deposit target.
     */
    function depositETH(bytes32 to)
        external
        payable
        override
        orCreateUser(msg.sender, to)
    {
        target.depositETH{value: msg.value}(to);
        emit Deposit(ETH_ID, to, msg.value);
    }

    /**
     * @param to the L2 address (bjjPubkey) of the deposit target.
     * @param amount the deposit amount.
     */
    function depositERC20(
        IERC20 token,
        bytes32 to,
        uint256 amount
    ) external override {
        uint256 balanceBeforeDeposit = token.balanceOf(address(this));
        token.safeTransferFrom(msg.sender, address(this), amount);
        uint256 balanceAfterDeposit = token.balanceOf(address(this));
        uint256 realAmount = balanceAfterDeposit - balanceBeforeDeposit;
        token.safeIncreaseAllowance(address(target), realAmount);

        (uint16 tokenId, uint256 finalAmount) = target.depositERC20(
            token,
            realAmount
        );
        emit Deposit(tokenId, to, finalAmount);
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

    /**
     * @dev create a user if not exist
     * @param bjjPubkey the L2 address (bjjPubkey)
     */
    modifier orCreateUser(address origin, bytes32 bjjPubkey) {
        if (target.getUserId(bjjPubkey) == 0) {
            uint16 userId = target.registerUser(origin, bjjPubkey);
            emit RegisterUser(msg.sender, userId, bjjPubkey);
        }
        _;
    }
}
