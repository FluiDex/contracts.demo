// SPDX-License-Identifier: MIT OR Apache-2.0

pragma solidity ^0.8.0;

import "./Operations.sol";

/// @title Fluidex storage contract
contract Storage {
    /// @notice First open priority request id
    uint64 public firstPriorityRequestId;

    /// @notice Total number of requests
    uint64 public totalOpenPriorityRequests;

    /// @notice Priority Operation container
    /// @member hashedPubData Hashed priority operation public data
    /// @member expirationBlock Expiration block number (ETH block) for this request (must be satisfied before)
    /// @member opType Priority operation type
    struct PriorityOperation {
        bytes20 hashedPubData;
        uint64 expirationBlock;
        Operations.OpType opType;
    }

    /// @dev Priority Requests mapping (request id - operation)
    /// @dev Contains op type, pubdata and expiration block of unsatisfied requests.
    /// @dev Numbers are in order of requests receiving
    mapping(uint64 => PriorityOperation) internal priorityRequests;

    /// @notice Check if priorityOp in queue has expired
    function checkPriorityOpExpiration() public view returns (bool) {
        if (totalOpenPriorityRequests == 0) return false;

        return
            priorityRequests[firstPriorityRequestId].expirationBlock <
            block.number;
    }

    /// @notice Verify priorityOp inside the calling public data match the priority queue
    /// @dev Calculates expiration block for request, store this request and emit NewPriorityRequest event
    /// @param _public_data Calling public_data
    /// @param _op_indexs indexs specify which op should be checked
    function verifyPriorityOp(
        bytes calldata _public_data,
        bytes calldata _op_indexs
    ) public view returns (bool _ret, uint64 _priorityRequestId) {
        //_op_indexs is uint16 being encode packed
        assert(_op_indexs.length % 2 == 0);
        assert(_public_data.length % Operations.TX_PUBDATA_BYTES == 0);

        require(
            !checkPriorityOpExpiration() ||
                //last chance: we put all effort on priority ops when they have expired
                _op_indexs.length / 2 == totalOpenPriorityRequests ||
                _public_data.length / Operations.TX_PUBDATA_BYTES ==
                _op_indexs.length / 2,
            "priority op must be handled before expiration"
        );

        _priorityRequestId = firstPriorityRequestId;

        for (uint256 i = 0; i < _op_indexs.length; i += 2) {
            //TODO: with compiler later than 0.8.10 we can use slice
            //uint pos = uint16(bytes2(_op_indexs[i:i+2]));
            uint256 pos = uint256(uint8(_op_indexs[i])) *
                256 +
                uint256(uint8(_op_indexs[i + 1]));
            assert(pos < _public_data.length);
            bytes20 hashedPubdata = priorityRequests[_priorityRequestId]
            .hashedPubData;
            if (Operations.hashPubData(_public_data, pos) != hashedPubdata) {
                return (false, _priorityRequestId);
            }
            _priorityRequestId++;
        }

        _ret = true;
    }

    /// @notice Saves priority request in storage
    /// @dev Calculates expiration block for request, store this request and emit NewPriorityRequest event
    /// @param _opType Rollup operation type
    /// @param _hashedPubData Hashed Operation pubdata
    function addPriorityRequest(
        Operations.OpType _opType,
        bytes20 _hashedPubData
    ) internal {
        // Expiration block is: current block number + priority expiration delta
        uint64 expirationBlock = uint64(
            block.number + Operations.PRIORITY_EXPIRATION
        );

        uint64 nextPriorityRequestId = firstPriorityRequestId +
            totalOpenPriorityRequests;

        priorityRequests[nextPriorityRequestId] = PriorityOperation({
            hashedPubData: _hashedPubData,
            expirationBlock: expirationBlock,
            opType: _opType
        });

        totalOpenPriorityRequests++;
    }
}
