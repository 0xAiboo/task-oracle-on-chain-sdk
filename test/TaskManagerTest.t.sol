// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/TaskManager.sol";
import "../src/Oracle.sol";
import "../src/interface/IDataEncoder.sol";

contract TaskManagerTest is Test {
    TaskManager public taskManager;
    Oracle public oracle;
    address public trustedSigner;
    uint256 private trustedSignerPrivateKey;

    function setUp() public {
        // 设置可信签名者地址和私钥
        trustedSignerPrivateKey = 1; // 私钥
        trustedSigner = vm.addr(trustedSignerPrivateKey); // 地址
        oracle = new Oracle(trustedSigner);
        taskManager = new TaskManager(address(oracle));
    }

    function testCreateTask() public {
        // 创建JobRequest数据
        IDataEncoder.JobRequest memory jobRequest = IDataEncoder.JobRequest({
            jobId: 1,
            requester: address(this),
            data: "test data",
            timestamp: block.timestamp
        });

        // 编码JobRequest数据
        bytes memory encodedJobRequest = taskManager.encodeJobRequest(
            jobRequest
        );

        // 调用createTask函数
        taskManager.createTask(encodedJobRequest);

        // 验证任务创建成功
        (
            uint256 id,
            address requester,
            string memory data,
            bool completed,
            string memory result
        ) = taskManager.tasks(0);
        assertEq(id, 0);
        assertEq(requester, address(this));
        assertEq(data, "test data");
        assertFalse(completed);
        assertEq(result, "");
    }

    function testCompleteTask() public {
        // 创建并编码JobRequest数据
        IDataEncoder.JobRequest memory jobRequest = IDataEncoder.JobRequest({
            jobId: 1,
            requester: address(this),
            data: "test data",
            timestamp: block.timestamp
        });
        bytes memory encodedJobRequest = taskManager.encodeJobRequest(
            jobRequest
        );
        taskManager.createTask(encodedJobRequest);

        // 创建并编码JobResult数据
        IDataEncoder.JobResult memory jobResult = IDataEncoder.JobResult({
            jobId: 0,
            result: "test result",
            timestamp: block.timestamp
        });
        bytes memory encodedJobResult = taskManager.encodeJobResult(jobResult);

        // 生成并签名结果哈希
        bytes32 resultHash = keccak256(abi.encodePacked(jobResult.result));
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(
            trustedSignerPrivateKey,
            oracle.toEthSignedMessageHash(resultHash)
        );
        bytes memory signature = abi.encodePacked(r, s, v);

        // 调用completeTask函数
        taskManager.completeTask(0, encodedJobResult, signature);

        // 验证任务完成
        (, , , bool completed, string memory result) = taskManager.tasks(0);
        assertTrue(completed);
        assertEq(result, "test result");
    }
}
