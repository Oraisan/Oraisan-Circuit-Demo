// SPDX-License-Identifier: GPL-3.0
pragma circom 2.0.0;
include "../../../libs/validators/signaturesverifier.circom";

template VerifySignature(nChainID, nSeconds, nNanos) {
    // signal input type;
    // signal input chainID[nChainID];
    signal input height; 
    signal input blockHash[32];
    signal input blockTime; 
    signal input partsTotal;
    signal input partsHash[32];
    signal input sigTimeSeconds;
    signal input sigTimeNanos;

    signal input pubKeys[32];
    signal input R8[32];
    signal input S[32];

    signal input PointA[4][3];
    signal input PointR[4][3];

    var i;
    var j;
    var type = 2;
    // chainID = "Oraichain"
    var chainID[nChainID] = [79, 114, 97, 105, 99, 104, 97, 105, 110];

    component sv = SignatureVerifier(nChainID, nSeconds, nNanos);
    sv.type <== type;

    for(i = 0; i < nChainID; i++) {
        sv.chainID[i] <== chainID[i];
    }

    sv.height <== height;
    
    for(i = 0; i < 32; i++) {
        sv.blockHash[i] <== blockHash[i];
    }

    sv.blockTime <== blockTime;
    sv.partsTotal <== partsTotal;

    for(i = 0; i < 32; i++) {
        sv.partsHash[i] <== partsHash[i];
    }
    

    sv.sigTimeSeconds <== sigTimeSeconds;
    sv.sigTimeNanos <== sigTimeNanos;

    for(i = 0; i < 32; i++) {
        sv.pubKeys[i] <== pubKeys[i];
        sv.R8[i] <== R8[i];
        sv.S[i] <== S[i];
    }

    for(i = 0; i < 4; i++) {
        for(j = 0; j < 3; j++) {
            sv.PointA[i][j] <== PointA[i][j];
            sv.PointR[i][j] <== PointR[i][j];
        }
    }
}
component main{public[height, blockHash, blockTime, pubKeys, R8, S]} = VerifySignature(9, 5, 4);