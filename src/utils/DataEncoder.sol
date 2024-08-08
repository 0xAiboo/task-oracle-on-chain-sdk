// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "../interface/IDataEncoder.sol";
contract DataEncoder is IDataEncoder {
    function encodeJobRequest(
        JobRequest memory jobRequest
    ) public pure returns (bytes memory) {
        return
            abi.encode(
                jobRequest.jobId,
                jobRequest.requester,
                jobRequest.data,
                jobRequest.timestamp
            );
    }

    function decodeJobRequest(
        bytes memory encodedData
    ) public pure returns (JobRequest memory) {
        (
            uint256 jobId,
            address requester,
            string memory data,
            uint256 timestamp
        ) = abi.decode(encodedData, (uint256, address, string, uint256));
        return JobRequest(jobId, requester, data, timestamp);
    }

    // 编码JobResult
    function encodeJobResult(
        JobResult memory jobResult
    ) public pure returns (bytes memory) {
        return
            abi.encode(jobResult.jobId, jobResult.result, jobResult.timestamp);
    }

    // 解码JobResult
    function decodeJobResult(
        bytes memory encodedData
    ) public pure returns (JobResult memory) {
        (uint256 jobId, string memory result, uint256 timestamp) = abi.decode(
            encodedData,
            (uint256, string, uint256)
        );
        return JobResult(jobId, result, timestamp);
    }
}
