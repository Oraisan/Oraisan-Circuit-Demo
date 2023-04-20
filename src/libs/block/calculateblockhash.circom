// SPDX-License-Identifier: GPL-3.0
pragma circom 2.0.0;
include "./hashblockelements.circom";
include "../utils/filedsblockheaderencode.circom";
include "../AVL_Tree/avlverifier.circom";

template CalculateBlockHash(nHeight, nSeconds, nNanos) {
    // signal input versionBlock;
    // signal input versionApp;
    // signal input chainID;
    signal input versionHash[32];
    signal input chainIDHash[32];

    signal input height;
    signal input time;
    signal input lastBlockHash[32];
    signal input lastPartsTotal;
    signal input lastPartsHash[32];
    signal input lastCommitHash[32];
    signal input dataHash[32];
    signal input validatorsHash[32];
    signal input nextValidatorsHash[32];
    signal input consensusHash[32];
    signal input appHash[32];
    signal input lastResultHash[32];
    signal input evidenceHash[32];
    signal input proposerAddress[20];

    signal output blockHash[32];
    var i;
    var j;
    
    component h = HashElementsBlock(nHeight, nSeconds, nNanos);
    for(i = 0; i < 32; i++) {
        h.versionHash[i] <== versionHash[i];
        h.chainIDHash[i] <== chainIDHash[i];
        h.lastBlockHash[i] <== lastBlockHash[i];
        h.lastPartsHash[i] <== lastPartsHash[i];
        
        h.lastCommitHash[i] <== lastCommitHash[i];
        h.dataHash[i] <== dataHash[i];
        h.validatorsHash[i] <== validatorsHash[i];
        h.nextValidatorsHash[i] <== nextValidatorsHash[i];
        h.consensusHash[i] <== consensusHash[i];
        h.appHash[i] <== appHash[i];
        h.lastResultHash[i] <== lastResultHash[i];
        h.evidenceHash[i] <== evidenceHash[i];
    }
    h.height <== height;
    h.time <== time;
    h.lastPartsTotal <== lastPartsTotal;
    for(i = 0; i < 20; i++) {
        h.proposerAddress[i] <== proposerAddress[i];
    }

    component root = CalculateRootFromLeafs(14);
    for(i = 0; i < 14; i++) {
        for(j = 0; j < 32; j++) {
            root.in[i][j] <== h.out[i][j];
        }
    }

    for(i = 0; i < 32; i++) {
        blockHash[i] <== root.out[i];
    }
}

template CalculateBlockHashFromDataAndVals() {
    var prefixBytes = 10;
    signal input dataHash[32];
    signal input validatorsHash[32];
    signal input parrentSiblings[3][32];
    signal output blockHash[32];

    var i;
    var j;
    component dataHashLeaf = HashBytesElemnt(prefixBytes, 32);
    for(i = 0; i < 32; i++) {
        dataHashLeaf.in[i] <== dataHash[i];
    }

    component validatorsHashLeaf = HashBytesElemnt(prefixBytes, 32);
    for(i = 0; i < 32; i++) {
        validatorsHashLeaf.in[i] <== validatorsHash[i];
    }

    component parrent = HashInner(32);
    for(i = 0; i < 32; i++) {
        parrent.L[i] <== dataHashLeaf.out[i];
        parrent.R[i] <== validatorsHashLeaf.out[i];
    }

    component root = CalculateRootFromSiblings(3);
    for(i = 0; i < 3; i++) {
        for(j = 0; j < 32; j++) {
            root.siblings[i][j] <== parrentSiblings[2-i][j];
        }
    }
    
    root.key <== 3;

    for(i = 0; i < 32; i++) {
        root.value[i] <== parrent.out[i];
    }

    for(i = 0; i < 32; i++) {
        blockHash[i] <== root.root[i];
    }

}