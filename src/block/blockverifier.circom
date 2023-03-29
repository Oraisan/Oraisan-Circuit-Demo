// SPDX-License-Identifier: GPL-3.0
pragma circom 2.0.0;
include "../libs/validators/validatorsverifier.circom";

template BlockVerifier(nBits) {
    signal input msg[nBits];
    
    signal input pubKeys[256];
    signal input sigs[512];

    signal input PointA[4][3];
    signal input PointR[4][3];

    var i;
    var j;
    component v = SignatureVerifier(nBits);
    
    for(i = 0; i < nBits; i++) {
        v.msg[i] <== msg[i];
    }

    for(i = 0; i < 256; i++) {
        v.pubKeys[i] <== pubKeys[i];
        v.R8[i] <== sigs[i];
    }

    for(i = 0; i < 255; i++) {
        v.S[i] <== sigs[i+257];
    }

    for(i = 0; i < 4; i++) {
        for(j = 0; j < 3; j++) {
            v.PointA[i][j] <== PointA[i][j];
            v.PointR[i][j] <== PointR[i][j];
        }
    }
}

component main{public[pubKeys]} = BlockVerifier(888);