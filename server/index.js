require('dotenv').config();
const { ethers } = require("ethers");

// 加载环境变量
const privateKey = process.env.PRIVATE_KEY;
const rpcUrl = process.env.RPC_URL;
const taskManagerAddress = process.env.TASK_MANAGER_ADDRESS;

// 初始化以太坊提供者和钱包
const provider = new ethers.providers.JsonRpcProvider(rpcUrl);
const wallet = new ethers.Wallet(privateKey, provider);

// TaskManager ABI（简化版，包含所需方法）
const taskManagerAbi = [
  "function encodeJobResult((uint256 jobId, string result, uint256 timestamp) calldata jobResult) external view returns (bytes memory)",
  "function completeTask(uint256 taskId, bytes memory encodedResult, bytes calldata signature) external",
  "event TaskCreated(uint256 indexed id, address indexed requester, string data)"
];

// 初始化 TaskManager 合约
const taskManager = new ethers.Contract(taskManagerAddress, taskManagerAbi, wallet);

// 监听 TaskCreated 事件
taskManager.on("TaskCreated", async (id, requester, data) => {
  console.log(`任务创建: ID = ${id}, 请求者 = ${requester}, 数据 = ${data}`);

  // 模拟链下计算
  const result = `computed result for ${data}`;
  const timestamp = Math.floor(Date.now() / 1000);

  // 创建 JobResult 对象
  const jobResult = {
    jobId: id.toNumber(),
    result: result,
    timestamp: timestamp
  };

  // 编码 JobResult 数据
  const encodedResult = await taskManager.encodeJobResult(jobResult);

  // 计算结果哈希
  const resultHash = ethers.utils.keccak256(encodedResult);

  // 对结果哈希进行签名
  const signature = await wallet.signMessage(ethers.utils.arrayify(resultHash));

  // 提交结果到链上
  const tx = await taskManager.completeTask(id, encodedResult, signature);
  await tx.wait();
  console.log(`任务 ${id} 已完成，交易哈希: ${tx.hash}`);
});

console.log("正在监听 TaskCreated 事件...");