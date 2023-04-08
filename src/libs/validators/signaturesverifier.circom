// SPDX-License-Identifier: GPL-3.0
pragma circom 2.0.0;

include "./msgheaderencode.circom";
include "../utils/convert.circom";
include "../../../electron-labs/verify.circom";
include "../../../node_modules/circomlib/circuits/comparators.circom";

template SignatureVerifier(nChainID, nSeconds, nNanos) {
    var nParts = 1;    
    var nBytes = 92 + nChainID + nSeconds + nNanos;

    signal input type;
    signal input chainID[nChainID];
    signal input height; 
    signal input blockHash[32];
    signal input blockTime; 
    signal input partsTotal;
    signal input partsHash[nParts][32];
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

    component msg = MsgEncode(nChainID, nSeconds, nNanos);
    msg.type <== type;

    for(i = 0; i < nChainID; i++) {
        msg.chainID[i] <== chainID[i];
    }
    
    msg.height <== height;
    
    for(i = 0; i < 32; i++) {
        msg.blockHash[i] <== blockHash[i];
    }

    msg.partsTotal <== partsTotal;
    for(i = 0; i < nParts; i++) {
        for(j = 0; j < 32; j++) {
            msg.partsHash[i][j] <== partsHash[i][j];
        }
    }

    msg.seconds <== sigTimeSeconds;
    msg.nanos <== sigTimeNanos;

    component msg2Bits[nBytes];
    for(i = 0; i < nBytes; i++) {
        msg2Bits[i] = BytesToBits(8);
        msg2Bits[i].in <== msg.out[i];
    }

    component pb2Bits[32];
    for(i = 0; i < 32; i++) {
        pb2Bits[i] = BytesToBits(8);
        pb2Bits[i].in <== pubKeys[i];
    }

    component r8ToBits[32];
    for(i = 0; i < 32; i++) {
        r8ToBits[i] = BytesToBits(8);
        r8ToBits[i].in <== R8[i];
    }

    component S2Bits[32];
    for(i = 0; i < 32; i++) {
        S2Bits[i] = BytesToBits(8);
        S2Bits[i].in <== S[i];
    }

    component v = Ed25519Verifier(8 * nBytes);

    for(i = 0; i < nBytes; i++) {
        for(j = 0; j < 8; j++) {
            v.msg[i * 8 + j] <== msg2Bits[i].out[j];
        }
    }

    for(i = 0; i < 32; i++) {
        for(j = 0; j < 8; j++) {
            v.A[i * 8 + j] <== pb2Bits[i].out[j];
            v.R8[i * 8 + j] <== r8ToBits[i].out[j];
        }
    }

    for(i = 0; i < 31; i++) {
        for(j = 0; j < 8; j++) {
            v.S[i * 8 + j] <== S2Bits[i].out[j];
        }
    }

    for(i = 0; i < 7; i++) {
        v.S[248 + i] <== S2Bits[31].out[i];
    }

    for(i = 0; i < 4; i++) {
        for(j = 0; j < 3; j++) {
            v.PointA[i][j] <== PointA[i][j];
            v.PointR[i][j] <== PointR[i][j];
        }
    }

    v.out === 1;
}