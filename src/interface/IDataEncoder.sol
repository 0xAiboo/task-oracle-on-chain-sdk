// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IDataEncoder {
    struct JobRequest {
        uint256 jobId; // 任务ID
        address requester; // 请求者地址
        string data; // 编码后的任务数据
        uint256 timestamp; // 时间戳
    }

    struct JobResult {
        uint256 jobId; // 任务ID
        string result; // 编码后的任务结果
        uint256 timestamp; // 时间戳
    }

    // 编码JobRequest
    function encodeJobRequest(
        JobRequest memory jobRequest
    ) external pure returns (bytes memory);

    // 解码JobRequest
    function decodeJobRequest(
        bytes memory encodedData
    ) external pure returns (JobRequest memory);

    // 编码JobResult
    function encodeJobResult(
        JobResult memory jobResult
    ) external pure returns (bytes memory);

    // 解码JobResult
    function decodeJobResult(
        bytes memory encodedData
    ) external pure returns (JobResult memory);
}
