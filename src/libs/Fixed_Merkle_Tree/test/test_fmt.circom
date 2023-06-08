// SPDX-License-Identifier: GPL-3.0
pragma circom 2.0.0;
include "../fmthash.circom";
include "../fmtverifier.circom";

template VerifyHash() {
    signal input L;
    signal input R;
    signal input hash;
    component h = HashInner();
    h.L <== L;
    h.R <== R;     
    
    h.out === hash;
}

template VerifyRoot(nSiblings) {
    signal input key;
    signal input value;
    signal input siblings[nSiblings];
    signal input root;

    component r = CalculateRootFromSiblings(nSiblings);
    r.key <== key;
    r.in <== value;

    for(var i = 0; i < nSiblings; i++) {
        r.siblings[i] <== siblings[i];
    }

    root  === r.root;
}

template VerifyHashedRoot(nLeafs) {
    signal input leafs[nLeafs];
    signal input root;

    component r = CalculateRootFromLeafs(nLeafs);
    for(var i = 0; i < nLeafs; i++) {
        r.in[i] <== leafs[i];
    }

    root  === r.out;
}
component main = VerifyRoot(32);
