// SPDX-License-Identifier: GPL-3.0
pragma circom 2.0.0;

include "./msgheaderencode.circom";
include "./verify.circom";
include "../utils/convert.circom";
include "../utils/shiftbytes.circom";
include "../../../node_modules/circomlib/circuits/comparators.circom";

template SignatureVerifier(nChainID) {
    var nBytes = 102 + nChainID;

    signal input type;
    signal input chainID[nChainID];
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

    component isTimeGreater = GreaterEqThan(80);
    isTimeGreater.in[0] <== sigTimeSeconds * 1000000000 + sigTimeNanos;
    isTimeGreater.in[1] <== blockTime;
    isTimeGreater.out === 1;

    component isTimeLesser = LessEqThan(80);
    isTimeLesser.in[0] <== sigTimeSeconds * 1000000000 + sigTimeNanos;
    isTimeLesser.in[1] <== blockTime + 10 * 1000000000;
    isTimeLesser.out === 1;

    component msg = MsgEncode(nChainID);
    msg.type <== type;

    for(i = 0; i < nChainID; i++) {
        msg.chainID[i] <== chainID[i];
    }
    
    msg.height <== height;
    
    for(i = 0; i < 32; i++) {
        msg.blockHash[i] <== blockHash[i];
    }

    msg.partsTotal <== partsTotal;
    for(i = 0; i < 32; i++) {
        msg.partsHash[i] <== partsHash[i];
    }
    

    msg.seconds <== sigTimeSeconds;
    msg.nanos <== sigTimeNanos;

    component v = Ed25519Verifier(nBytes);

    for(i = 0; i < nBytes; i++) {
        v.msg[i] <== msg.out[i];
    }
    v.length <== msg.length;

    for(i = 0; i < 32; i++) {
        v.A[i] <== pubKeys[i];
        v.R8[i] <== R8[i];
        v.S[i] <== S[i];
    }

    for(i = 0; i < 4; i++) {
        for(j = 0; j < 3; j++) {
            v.PointA[i][j] <== PointA[i][j];
            v.PointR[i][j] <== PointR[i][j];
        }
    }

    v.out === 1;
}