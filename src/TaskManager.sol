// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Oracle.sol";
import "./interface/ITaskManager.sol";
import "./utils/DataEncoder.sol";

contract TaskManager is ITaskManager, DataEncoder {
    uint256 public nextTaskId;
    mapping(uint256 => Task) public tasks;
    Oracle private immutable oracle;

    constructor(address oracleAddress) {
        oracle = Oracle(oracleAddress);
    }
    // 创建任务
    function createTask(bytes memory encodedData) external {
        JobRequest memory jobRequest = decodeJobRequest(encodedData); // 解码任务请求
        uint256 taskId = nextTaskId++;
        tasks[taskId] = Task(
            taskId,
            jobRequest.requester,
            jobRequest.data,
            false,
            ""
        );
        emit TaskCreated(taskId, jobRequest.requester, jobRequest.data);
    }
    // 完成任务
    function completeTask(
        uint256 taskId,
        bytes memory encodedResult,
        bytes calldata signature
    ) external {
        Task storage task = tasks[taskId];
        if (task.completed) revert ErrorTaskAlreadyCompleted();

        JobResult memory jobResult = decodeJobResult(encodedResult); // 解码任务结果
        if (jobResult.jobId != taskId) revert ErrorTaskNotFound();

        bytes32 resultHash = keccak256(abi.encodePacked(jobResult.result));
        if (!oracle.isValidResult(resultHash, signature))
            revert ErrorInvalidResultSignature();

        task.completed = true;
        task.result = jobResult.result;
        emit TaskCompleted(taskId, jobResult.result);
    }
}
