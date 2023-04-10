pragma circom 2.0.0;

include "../../../node_modules/circomlib/circuits/switcher.circom";
include "avlhash.circom";


template AVLVerifierLevel(nBytes) {
    signal input st_top;

    signal input sibling[nBytes];
    signal input lrbit;
    signal input child[nBytes];
    signal output root[nBytes];

    component switcher[nBytes];
    component proofHash = HashInner(nBytes);
    for(var i = 0; i < nBytes; i++) {
        switcher[i] = Switcher();
        switcher[i].L <== child[i];
        switcher[i].R <== sibling[i];
        switcher[i].sel <== lrbit;
    }

    for(var i = 0; i < nBytes; i++) {
        proofHash.L[i] <== switcher[i].outL;
        proofHash.R[i] <== switcher[i].outR;
    }

    for(var i = 0; i < nBytes; i++) {
        root[i] <== (proofHash.out[i] - child[i]) * st_top + child[i];
    }
}