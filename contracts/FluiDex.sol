// SPDX-License-Identifier: MIT OR Apache-2.0

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "hardhat/console.sol"; // for debugging

import "./IFluiDex.sol";
import "./IVerifier.sol";

/**
 * @title FluiDexDemo
 */
contract FluiDexDemo is AccessControl, IFluiDex, Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    bytes32 public constant PLUGIN_ADMIN_ROLE = keccak256("PLUGIN_ADMIN_ROLE");
    bytes32 public constant DELEGATE_ROLE = keccak256("DELEGATE_ROLE");

    /// hard limit for ERC20 tokens
    uint16 constant TOKEN_NUM_LIMIT = 65535;
    /// hard limit for users
    uint16 constant USER_NUM_LIMIT = 65535;
    /// use 0 representing ETH in tokenId
    uint16 constant ETH_ID = 0;

    IVerifier verifier;
    event VerifierChange(IVerifier prev, IVerifier now);

    uint256 GENESIS_ROOT;
    mapping(uint256 => uint256) public state_roots;
    mapping(uint256 => BlockState) public block_states;

    uint16 public tokenNum;
    mapping(uint16 => address) public tokenIdToAddr;
    mapping(address => uint16) public tokenAddrToId;

    uint16 public userNum;
    mapping(uint16 => UserInfo) public userIdToUserInfo;
    mapping(bytes32 => uint16) public userBjjPubkeyToUserId;

    constructor(uint256 _genesis_root, IVerifier _verifier) {
        GENESIS_ROOT = _genesis_root;
        verifier = _verifier;
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setRoleAdmin(PLUGIN_ADMIN_ROLE, DEFAULT_ADMIN_ROLE);
        _setRoleAdmin(DELEGATE_ROLE, DEFAULT_ADMIN_ROLE);
        grantRole(PLUGIN_ADMIN_ROLE, msg.sender);
        grantRole(DELEGATE_ROLE, msg.sender);
    }

    /**
     * @notice this is a dev function only for upgrade verifier
     */
    function setVerifier(IVerifier _verifier)
        external
        onlyRole(PLUGIN_ADMIN_ROLE)
    {
        IVerifier prev = verifier;
        verifier = _verifier;
        emit VerifierChange(prev, _verifier);
    }

    /**
     * @notice request to add a new ERC20 token
     * @param tokenAddr the ERC20 token address
     * @return the new ERC20 token tokenId
     */
    function addToken(address tokenAddr)
        external
        override
        nonReentrant
        onlyRole(DELEGATE_ROLE)
        returns (uint16)
    {
        require(tokenAddrToId[tokenAddr] == 0, "token existed");
        tokenNum++;
        require(tokenNum < TOKEN_NUM_LIMIT, "token num limit reached");

        uint16 tokenId = tokenNum;
        tokenIdToAddr[tokenId] = tokenAddr;
        tokenAddrToId[tokenAddr] = tokenId;

        return tokenId;
    }

    /**
     * @param to the L2 address (bjjPubkey) of the deposit target.
     */
    function depositETH(bytes32 to)
        external
        payable
        override
        onlyRole(DELEGATE_ROLE)
    {}

    /**
     * @param amount the deposit amount.
     */
    function depositERC20(IERC20 token, bytes32 to， uint256 amount)
        external
        override
        nonReentrant
        tokenExist(token)
        onlyRole(DELEGATE_ROLE)
        returns (uint16 tokenId, uint256 realAmount)
    {
        tokenId = tokenAddrToId[address(token)];

        uint256 balanceBeforeDeposit = token.balanceOf(address(this));
        token.safeTransferFrom(msg.sender, address(this), amount);
        uint256 balanceAfterDeposit = token.balanceOf(address(this));
        realAmount = balanceAfterDeposit - balanceBeforeDeposit;
    }

    /**
     * @dev this won't verify the pubkey
     * @param ethAddr the L1 address
     * @param bjjPubkey the L2 address (bjjPubkey)
     */
    function registerUser(address ethAddr, bytes32 bjjPubkey)
        external
        override
        onlyRole(DELEGATE_ROLE)
        returns (uint16 userId)
    {
        require(userBjjPubkeyToUserId[bjjPubkey] == 0, "user existed");
        userNum++;
        require(userNum < USER_NUM_LIMIT, "user num limit reached");

        userId = userNum;
        userIdToUserInfo[userId] = UserInfo({
            ethAddr: ethAddr,
            bjjPubkey: bjjPubkey
        });
        userBjjPubkeyToUserId[bjjPubkey] = userId;
    }

    function getBlockStateByBlockId(uint256 _block_id)
        external
        view
        override
        returns (BlockState)
    {
        return block_states[_block_id];
    }

    /**
     * @notice to verify the validity of a sole block
     * @param _public_inputs the public inputs of this block
     * @param _serialized_proof the serialized proof of this block
     * @param _public_data the serialized tx data inside this block (data availability)
     * @return true if the block was accepted
     */
    function verifyBlock(
        uint256[] calldata _public_inputs,
        uint256[] calldata _serialized_proof,
        bytes calldata _public_data
    ) public view returns (bool) {
        // _public_inputs[2]/[3] is the low/high 128bit of sha256 hash of _public_data respectively
        require(_public_inputs.length >= 4);

        bytes32 h = sha256(_public_data);

        console.logBytes(_public_data);
        console.logBytes32(h);

        uint256 h_lo = 0;
        for (uint256 i = 0; i < 16; i++) {
            uint256 tmp = uint256(uint8(h[i + 16])) << (120 - 8 * i);
            h_lo = h_lo + tmp;
        }
        uint256 h_hi = 0;
        for (uint256 i = 0; i < 16; i++) {
            uint256 tmp = uint256(uint8(h[i])) << (120 - 8 * i);
            h_hi = h_hi + tmp;
        }

        assert(_public_inputs[2] == h_hi);
        assert(_public_inputs[3] == h_lo);

        return
            verifier.verify_serialized_proof(_public_inputs, _serialized_proof);
    }

    /**
     * @notice request to submit a new l2 block, same parameters with verifySubmitting
     * @return true if the block was accepted
     */
    function submitBlock(
        uint256 _block_id,
        uint256[] calldata _public_inputs,
        uint256[] calldata _serialized_proof,
        bytes calldata _public_data
    ) external override returns (bool) {
        require(_public_inputs.length >= 2);
        if (_block_id == 0) {
            assert(_public_inputs[0] == GENESIS_ROOT);
        } else {
            assert(_public_inputs[0] == state_roots[_block_id - 1]);
        }

        if (_serialized_proof.length != 0) {
            bool ret = verifyBlock(
                _public_inputs,
                _serialized_proof,
                _public_data
            );

            if (!ret) {
                return ret;
            }

            if (_block_id > 0) {
                require(
                    block_states[_block_id - 1] == BlockState.Verified,
                    "Previous block must be verified"
                );
            }
            require(
                block_states[_block_id] != BlockState.Verified,
                "Block must not be submitted twice"
            );
            block_states[_block_id] = BlockState.Verified;
        } else {
            // mark a block as Committed directly, because we may
            // temporarily run out of proving resource.
            // note: Committing a block without a rollback/revert mechanism should
            // only happen in demo version!
            if (_block_id > 0) {
                assert(block_states[_block_id - 1] != BlockState.Empty);
            }
            assert(block_states[_block_id] == BlockState.Empty);
            block_states[_block_id] = BlockState.Committed;
        }

        state_roots[_block_id] = _public_inputs[1];
        return true;
    }

    /**
     * @notice request to submit a new l2 block
     * @param _block_id the l2 block id
     * @param _public_inputs the public inputs of this block
     * @param _serialized_proof the serialized proof of this block
     * @return true if the block was accepted
     */
    function submitBlockLegacy(
        uint256 _block_id,
        uint256[] calldata _public_inputs,
        uint256[] calldata _serialized_proof
    ) external returns (bool) {
        // _public_inputs[0] is previous_state_root
        // _public_inputs[1] is new_state_root
        require(_public_inputs.length >= 2);
        if (_block_id == 0) {
            assert(_public_inputs[0] == GENESIS_ROOT);
        } else {
            assert(_public_inputs[0] == state_roots[_block_id - 1]);
        }

        if (_serialized_proof.length != 0) {
            // TODO: hash inputs and then pass into verifier
            assert(
                verifier.verify_serialized_proof(
                    _public_inputs,
                    _serialized_proof
                )
            );
            if (_block_id > 0) {
                assert(block_states[_block_id - 1] == BlockState.Verified);
            }
            assert(block_states[_block_id] != BlockState.Verified);
            block_states[_block_id] = BlockState.Verified;
        } else {
            // mark a block as Committed directly, because we may
            // temporarily run out of proving resource.
            // note: Committing a block without a rollback/revert mechanism should
            // only happen in demo version!
            if (_block_id > 0) {
                assert(block_states[_block_id - 1] != BlockState.Empty);
            }
            assert(block_states[_block_id] == BlockState.Empty);
            block_states[_block_id] = BlockState.Committed;
        }
        state_roots[_block_id] = _public_inputs[1];

        return true;
    }

    /**
     * @dev require a token is registered
     * @param token the ERC20 token address
     */
    modifier tokenExist(IERC20 token) {
        require(tokenAddrToId[address(token)] != 0, "non exist token");
        _;
    }

    /**
     * @param tokenId tokenId
     * @return tokenAddr
     */
    function getTokenAddr(uint16 tokenId)
        external
        view
        override
        returns (address)
    {
        return tokenIdToAddr[tokenId];
    }

    /**
     * @param tokenAddr tokenAddr
     * @return tokenId
     */
    function getTokenId(address tokenAddr)
        external
        view
        override
        returns (uint16)
    {
        return tokenAddrToId[tokenAddr];
    }

    /**
     * @param userId userId
     * @return UserInfo
     */
    function getUserInfo(uint16 userId)
        external
        view
        override
        returns (UserInfo memory)
    {
        return userIdToUserInfo[userId];
    }

    /**
     * @param bjjPubkey user's pubkey
     * @return userId, returns 0 if not exist
     */
    function getUserId(bytes32 bjjPubkey)
        external
        view
        override
        returns (uint16)
    {
        return userBjjPubkeyToUserId[bjjPubkey];
    }
}
