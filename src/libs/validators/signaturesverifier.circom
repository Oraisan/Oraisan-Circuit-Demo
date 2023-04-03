// SPDX-License-Identifier: GPL-3.0
pragma circom 2.0.0;
// include "../../../node_modules/circomlib/circuits/eddsa.circom";
include "../utils/convert.circom";
include "../../../electron-labs/verify.circom";

template SignatureVerifier(nBits) {
    signal input msg[nBits];
    signal input pubKeys[256];
    signal input R8[256];
    signal input S[255];

    signal input PointA[4][3];
    signal input PointR[4][3];

    var i;
    var j;

    component v = Ed25519Verifier(nBits);
    for(i = 0; i < nBits; i++) {
        v.msg[i] <== msg[i];
    }

    for(i = 0; i < 256; i++) {
            v.A[i] <== pubKeys[i];
            v.R8[i] <== R8[i];
    }

    for(i = 0; i < 255; i ++) {
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

template SignatureVerifierByBytes(nBytes) {
    signal input pubKeys[32];
    signal input R8[32];
    signal input S[32];
    signal input msg[nBytes];

    signal input PointA[4][3];
    signal input PointR[4][3];

    var i;
    var j;

    component msg2Bits[nBytes];
    for(i = 0; i < nBytes; i++) {
        msg2Bits[i] = BytesToBits(8);
        msg2Bits[i].in <== msg[i];
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