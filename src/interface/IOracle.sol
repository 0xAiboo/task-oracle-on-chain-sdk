// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IOracle {
    error ErrorInvalidResultSignature();
    // 验证成功时事件
    event ResultValidated(
        bytes32 indexed resultHash,
        address indexed validator
    );
    function setTrustedSigner(address _trustedSigner) external;

    function isValidResult(
        bytes32 resultHash,
        bytes memory signature
    ) external view returns (bool);

    function toEthSignedMessageHash(
        bytes32 hash
    ) external pure returns (bytes32);

    function validateResult(
        bytes32 resultHash,
        bytes memory signature
    ) external;
}
