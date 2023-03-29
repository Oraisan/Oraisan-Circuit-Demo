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