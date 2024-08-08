// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "./interface/IOracle.sol";
contract Oracle is Ownable(msg.sender), IOracle {
    using ECDSA for bytes32;
    // 可信签名者地址
    address public trustedSigner;
    constructor(address _trustedSigner) {
        trustedSigner = _trustedSigner;
    }

    function setTrustedSigner(address _trustedSigner) external onlyOwner {
        trustedSigner = _trustedSigner;
    }
    // 验证由可信签名者签名的函数
    function isValidResult(
        bytes32 resultHash,
        bytes memory signature
    ) public view returns (bool) {
        return
            toEthSignedMessageHash(resultHash).recover(signature) ==
            trustedSigner;
    }

    function toEthSignedMessageHash(
        bytes32 hash
    ) public pure returns (bytes32) {
        return
            keccak256(
                abi.encodePacked("\x19Ethereum Signed Message:\n32", hash)
            );
    }
     // 验证结果
    function validateResult(
        bytes32 resultHash, 
        bytes memory signature
    ) external {
        if(!isValidResult(resultHash, signature)) revert ErrorInvalidResultSignature();
        emit ResultValidated(resultHash, msg.sender);
    }
}
