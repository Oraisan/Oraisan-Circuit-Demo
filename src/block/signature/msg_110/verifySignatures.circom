// SPDX-License-Identifier: GPL-3.0
pragma circom 2.0.0;
include "../../../libs/validators/signaturesverifier.circom";
include "../../../libs/utils/convert.circom";

template VerifySignature(nChainID, nSeconds, nNanos) {
    // signal input type;
    // signal input chainID[nChainID];
    signal input height; 
    signal input blockHash[2];
    signal input blockTime; 
    signal input partsTotal;
    signal input partsHash[2];
    signal input sigTimeSeconds;
    signal input sigTimeNanos;

    signal input pubKeys[2];
    signal input R8[2];
    signal input S[2];

    signal input PointA[4][3];
    signal input PointR[4][3];

    var i;
    var j;
    var type = 2;
    // chainID = "Oraichain"
    var chainID[nChainID] = [79, 114, 97, 105, 99, 104, 97, 105, 110];

    component blockHashToByte[2];
    component partsHashToByte[2];
    component pubKeysToByte[2];
    component R8ToByte[2];
    component SToByte[2];

    for(i = 0; i < 2; i++) {
        blockHashToByte[i] =  NumToBytes(16);
        blockHashToByte[i].in <== blockHash[i];

        partsHashToByte[i] =  NumToBytes(16);
        partsHashToByte[i].in <== partsHash[i];

        pubKeysToByte[i] =  NumToBytes(16);
        pubKeysToByte[i].in <== pubKeys[i];

        R8ToByte[i] =  NumToBytes(16);
        R8ToByte[i].in <== R8[i];

        SToByte[i] =  NumToBytes(16);
        SToByte[i].in <== S[i];
    }

    component sv = SignatureVerifier(nChainID, nSeconds, nNanos);
    sv.type <== type;

    for(i = 0; i < nChainID; i++) {
        sv.chainID[i] <== chainID[i];
    }

    sv.height <== height;
    
    for(i = 0; i < 16; i++) {
        sv.blockHash[i] <== blockHashToByte[0].out[i];
        sv.blockHash[i + 16] <== blockHashToByte[1].out[i];
    }

    sv.blockTime <== blockTime;
    sv.partsTotal <== partsTotal;

    for(i = 0; i < 16; i++) {
        sv.partsHash[i] <== partsHashToByte[0].out[i];
        sv.partsHash[i + 16] <== partsHashToByte[1].out[i];
    }
    

    sv.sigTimeSeconds <== sigTimeSeconds;
    sv.sigTimeNanos <== sigTimeNanos;

    for(i = 0; i < 16; i++) {
        sv.pubKeys[i] <== pubKeysToByte[0].out[i];
        sv.pubKeys[i + 16] <== pubKeysToByte[1].out[i];

        sv.R8[i] <== R8ToByte[0].out[i];
        sv.R8[i + 16] <== R8ToByte[1].out[i];

        sv.S[i] <== SToByte[0].out[i];
        sv.S[i + 16] <== SToByte[1].out[i];
    }

    for(i = 0; i < 4; i++) {
        for(j = 0; j < 3; j++) {
            sv.PointA[i][j] <== PointA[i][j];
            sv.PointR[i][j] <== PointR[i][j];
        }
    }
}
component main{public[height, blockHash, blockTime, pubKeys]} = VerifySignature(9, 5, 4);