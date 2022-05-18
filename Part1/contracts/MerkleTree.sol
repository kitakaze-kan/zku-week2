//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import {PoseidonT3} from "./Poseidon.sol"; //an existing library to perform Poseidon hash on solidity
import "./verifier.sol"; //inherits with the MerkleTreeInclusionProof verifier contract

contract MerkleTree is Verifier {
    uint256[] public hashes; // the Merkle tree in flattened array form
    uint256 public index = 0; // the current index of the first unfilled leaf
    uint256 public root; // the current Merkle root

    constructor() {
        // [assignment] initialize a Merkle tree of 8 with blank leaves
        uint256 n = 8;
        uint256 offset = 0;

        hashes = [
            uint256(0),
            uint256(0),
            uint256(0),
            uint256(0),
            uint256(0),
            uint256(0),
            uint256(0),
            uint256(0)
        ];

        while (n > 0) {
            for (uint256 i = 0; i < n - 1; i += 2) {
                hashes.push(
                    PoseidonT3.poseidon(
                        [hashes[i + offset], hashes[i + 1 + offset]]
                    )
                );
            }

            offset += n;
            n = n / 2;
        }
    }

    function insertLeaf(uint256 hashedLeaf) public returns (uint256) {
        // [assignment] insert a hashed leaf into the Merkle tree
        uint256 n = hashes.length;
        uint256 offset = 0;

        bool shouldInsert = true;
        for (uint256 i = 0; i < n; i++) {
            if (hashes[i] == 0) {
                hashes[i] = hashedLeaf;
                shouldInsert = false;
                break;
            }
        }

        while (n > 0) {
            for (uint256 i = 0; i < n - 1; i += 2) {
                hashes.push(
                    PoseidonT3.poseidon(
                        [hashes[i + offset], hashes[i + 1 + offset]]
                    )
                );
            }

            offset += n;
            n = n / 2;
        }
        return hashes[hashes.length - 1];
    }

    function verify(
        uint256[2] memory a,
        uint256[2][2] memory b,
        uint256[2] memory c,
        uint256[1] memory input
    ) public view returns (bool) {
        // [assignment] verify an inclusion proof and check that the proof root matches current root
        return verifyProof(a, b, c, input);
    }
}
