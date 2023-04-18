pragma circom 2.0.0;

include "../sha256/sha256standard.circom";


template HashInner(n) {
    signal input L[n];
    signal input R[n];
    signal output out[32];

    component h = Sha256Bytes(2*n + 1);

    h.in[0] <== 1;

    for(var i = 0; i < n; i++) {
        h.in[i+1] <== L[i];
        h.in[i+n+1] <== R[i];
    }

     for(var i = 0; i < 32; i++) {
        out[i] <== h.out[i];
    }
}


template HashLeaf(n) {
    signal input in[n];
    signal output out[32];
    // for(var i = 0; i < n; i++) {
    //     log("std", i , in[i]);
    // }
    component h = Sha256Bytes(n+1);
    h.in[0] <== 0;
    for(var i = 0; i < n; i++) {
        h.in[i+1] <== in[i];
    }

    for(var i = 0; i < 32; i++) {
        out[i] <== h.out[i];
    }
}
