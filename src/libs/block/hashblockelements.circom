// SPDX-License-Identifier: GPL-3.0
pragma circom 2.0.0;
include "../utils/filedsblockheaderencode.circom";
include "../AVL_Tree/avlhash.circom";

template HashBytesElemnt(prefix, nBytes) {
    signal input in[nBytes];
    signal output out[32];

    component ec = CdcEncodeBytes(prefix, nBytes);
    for(var i = 0; i < nBytes; i++) {
        ec.bytesValue[i] <== in[i];
    }

    component h = HashLeaf(nBytes + 2);
    for(var i = 0; i < nBytes + 2; i++) {
        h.leaf[i] <== ec.out[i];
    }

    for(var i = 0; i < 32; i++) {
        out[i] <== h.out[i];
    }
}   

template HashIntElement(prefix, nBytes) {
    signal input in;
    signal output out[32];

    component ec = CdcEncodeInt(prefix, nBytes);
    ec.intValue <== in;

    component h = HashLeaf(nBytes + 1);
    for(var i = 0; i < nBytes + 1; i++) {
        h.leaf[i] <== ec.out[i];
    }

    for(var i = 0; i < 32; i++) {
        out[i] <== h.out[i];
    }
}

template HashBlockTime(prefixSeconds, prefixNanos, nSeconds, nNanos) {
    signal input in;
    signal output out[32];

    component ec = CdcEncodeBlockTime(prefixSeconds, prefixNanos, nSeconds, nNanos);
    ec.blockTime <== in;

    component h = HashLeaf(nSeconds + nNanos + 2);
    for(var i = 0; i < nSeconds + nNanos + 2; i++) {
        h.leaf[i] <== ec.out[i];
    }

    for(var i = 0; i < 32; i++) {
        out[i] <== h.out[i];
    }
}

template HashBlockID(prefixHash, prefixParts, prefixPartsHash, prefixPartsTotal) {

    signal input blockHash[32];
    signal input partsTotal;
    signal input partsHash[32];
    signal output out[32];
    var i;
    var j;

    component ec = CdcEncodeBlockID(prefixHash, prefixParts, prefixPartsHash, prefixPartsTotal);
    for(i = 0; i < 32; i++) {
        ec.blockHash[i] <== blockHash[i];
    }
    ec.partsTotal <== partsTotal;

    for(i = 0; i < 32; i++) {
        ec.partsHash[i] <== partsHash[i];
    }
    

    component h = HashLeaf(72);
    for(var i = 0; i < 72; i++) {
        h.leaf[i] <== ec.out[i];
    }

    for(var i = 0; i < 32; i++) {
        out[i] <== h.out[i];
    }
}

template HashElementsBlock() {
    var nSeconds = 5;
    var nNanos = 5;
    var nHeight = 4;

    var prefixSeconds = 8;
    var prefixNanos = 16;
    var prefixInt = 8;
    var prefixBytes = 10;
    var prefixHash = 10;
    var prefixParts = 18;
    var prefixPartsTotal = 8;
    var prefixPartsHash = 18;

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
    
    signal output out[14][32];
    var i;
    var j;

    component heightHash = HashIntElement(prefixInt, nHeight);
    heightHash.in <== height;

    component blockTimeHash = HashBlockTime(prefixSeconds, prefixNanos, nSeconds, nNanos);
    blockTimeHash.in <== time;

    component lastBlockIDHash = HashBlockID(prefixHash, prefixParts, prefixPartsHash, prefixPartsTotal);
    for(i = 0; i < 32; i++) {
        lastBlockIDHash.blockHash[i] <== lastBlockHash[i];
    }
    lastBlockIDHash.partsTotal <== lastPartsTotal;

    for(i = 0; i < 32; i++) {
        lastBlockIDHash.partsHash[i] <== lastPartsHash[i];
    }
    

    component bytesHash[8];
    for(i = 0; i < 8; i++) {
        bytesHash[i] = HashBytesElemnt(prefixBytes, 32);
    }
    for(i = 0; i < 32; i++) {
        bytesHash[0].in[i] <== lastCommitHash[i];
        bytesHash[1].in[i] <== dataHash[i];
        bytesHash[2].in[i] <== validatorsHash[i];
        bytesHash[3].in[i] <== nextValidatorsHash[i];
        bytesHash[4].in[i] <== consensusHash[i];
        bytesHash[5].in[i] <== appHash[i];
        bytesHash[6].in[i] <== lastResultHash[i];
        bytesHash[7].in[i] <== evidenceHash[i];
    }

    component proposerAddressHash = HashBytesElemnt(prefixBytes, 20);
    for(i = 0; i < 20; i++) {
        proposerAddressHash.in[i] <== proposerAddress[i];
    }

    for(i = 0; i < 32; i++) {
        out[0][i] <== versionHash[i];
        out[1][i] <== chainIDHash[i];
        out[2][i] <== heightHash.out[i];
        out[3][i] <== blockTimeHash.out[i];
        out[4][i] <== lastBlockIDHash.out[i];
        for(j = 0; j < 8; j++) {
            out[5+j] <== bytesHash[j].out[i];
        }
        out[13][i] <== proposerAddressHash.out[i];
    }
}