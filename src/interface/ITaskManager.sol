// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ITaskManager {
    struct Task {
        uint256 id; //ID
        address requester; // 请求者地址
        string data; // 编码后的任务数据
        bool completed; // 任务是否完成
        string result; // 编码后的任务结果
    }
    // 任务创建事件
    event TaskCreated(uint256 id, address requester, string data);
    // 任务完成事件
    event TaskCompleted(uint256 id, string result);

    error ErrorTaskAlreadyCompleted();
    error ErrorInvalidResultSignature();
    error ErrorTaskNotFound();

    function createTask(bytes memory encodedData) external;

    function completeTask(
        uint256 taskId,
        bytes memory encodedResult,
        bytes calldata signature
    ) external;
}
