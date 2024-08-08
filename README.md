# 预言机和任务管理合约

该仓库包含三个主要的 Solidity 智能合约：`DataEncoder.sol`、`Oracle.sol` 和 `TaskManager.sol`，以及它们各自的接口文件。这些合约共同工作，管理和验证链上任务与链下计算之间的交互。

## 合约概述

### DataEncoder.sol

`DataEncoder.sol` 合约负责数据的编码和解码。它定义了两个结构体 `JobRequest` 和 `JobResult`，并提供了编码和解码这些结构体的方法。

### Oracle.sol

合约用于验证链下计算结果的签名。它定义了一个可信签名者地址，并提供验证签名的方法。

主要功能：

    •	setTrustedSigner：设置可信签名者地址。
    •	isValidResult：验证结果哈希值是否由可信签名者签名。
    •	toEthSignedMessageHash：将普通哈希值转换为以太坊签名消息格式的哈希值。
    •	validateResult：验证结果签名并触发事件。

### TaskManager.sol

TaskManager.sol 合约管理任务的创建和完成。它使用 DataEncoder 合约进行数据编码和解码，并使用 Oracle 合约进行结果验证。

主要功能：

    •	createTask：创建新任务并触发事件。
    •	completeTask：完成任务，验证结果签名，并触发事件。


## 链下计算交互

### 任务创建
用户通过调用 TaskManager 合约的 createTask 函数创建任务，任务数据经过编码后存储在链上。

### 链下计算
链下系统监听任务创建事件，获取任务数据，进行计算，并生成计算结果。

### 结果签名
链下系统使用可信签名者的私钥对计算结果进行签名。

### 提交结果
链下系统将编码后的结果和签名提交到 TaskManager 合约的 completeTask 函数进行验证。

### 结果验证
TaskManager 合约调用 Oracle 合约的 isValidResult 函数验证签名的有效性，如果验证通过，则标记任务完成并存储结果。

# server
## index.js 

介绍

使用 ethers.js 库编写的链下计算脚本，主要用于监听 TaskManager 合约的任务创建事件，执行链下计算，签名计算结果，并将结果提交到链上。该脚本模拟了实际使用场景中的链上链下交互过程。

功能概述

	1.	监听任务创建事件：链下系统监听 TaskManager 合约的 TaskCreated 事件。
	2.	执行链下计算：根据任务数据执行链下计算。
	3.	签名计算结果：使用可信签名者的私钥对计算结果进行签名。
	4.	提交结果到链上：将签名后的计算结果提交到链上合约。