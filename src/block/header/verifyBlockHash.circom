// SPDX-License-Identifier: GPL-3.0
pragma circom 2.0.0;
include "../../libs/block/calculateblockhash.circom";

template VerifyBlockHash(nHeight) {
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

    signal input blockHash[32];
    
    var i;
    var j;
    
    component h = CalculateBlockHash(nHeight);

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

    for(i = 0; i < 32; i++) {
        blockHash[i] === h.blockHash[i];
    }

}
component main{public[chainIDHash, height, time, dataHash, validatorsHash]} = VerifyBlockHash(4);