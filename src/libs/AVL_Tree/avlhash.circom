pragma circom 2.0.0;

include "../sha256/sha256standard.circom";
include "../../../node_modules/circomlib/circuits/comparators.circom";
include "../../../node_modules/circomlib/circuits/switcher.circom";

template HashChilds(n) {
    signal input L[n];
    signal input R[n];
    signal output out[32];

    var i;
    var right;
    var left;

    component h = HashInner(n);
    for(i = 0; i < n; i++) {
        h.L[i] <== L[i];
        h.R[i] <== R[i];
        
        right += R[i];
        left += L[i];
    }    

    component isOneLeaf = IsZero();
    isOneLeaf.in <== left * right;

    component sw[32];
    for(i = 0; i < 32; i++) {
        sw[i] = Switcher();
        sw[i].sel <== isOneLeaf.out;
        sw[i].L <== h.out[i];
        sw[i].R <== L[i] + R[i];
        out[i] <== sw[i].outL;
    }

}

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
    component h = Sha256Bytes(n+1);
    h.in[0] <== 0;
    for(var i = 0; i < n; i++) {
        h.in[i+1] <== in[i];
    }

    for(var i = 0; i < 32; i++) {
        out[i] <== h.out[i];
    }
}
