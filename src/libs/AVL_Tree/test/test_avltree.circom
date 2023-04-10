// SPDX-License-Identifier: GPL-3.0
pragma circom 2.0.0;
include "../avlverifier.circom";
include "../avlhash.circom";

template VerifyRoot(nLeafs) {
    signal input in[nLeafs][32];
    signal input root[32];

    var i;
    var j;

    component h[nLeafs];

    for(i = 0; i < nLeafs; i++) {
        h[i] = HashLeaf(32);
        for(j = 0; j < 32; j++) {
            h[i].in[j] <== in[i][j];
        }
    }

    component r = CalculateRootFromLeafs(nLeafs);
    for(i = 0; i < nLeafs; i++) {
        for(j = 0; j < 32; j++) {
            r.in[i][j] <== h[i].out[j];
        }
    }

    for(i = 0; i < 32; i++) {
        root[i] === r.out[i];
    }

}

template VerifyRootBySiblings(nSiblings) {
    signal input key;
    signal input in[32];

    signal input siblings[nSiblings][32];
    signal input root[32];

    var i;
    var j;

    component h = HashLeaf(32);
    for(i = 0; i < 32; i++) {
        h.in[i] <== in[i];
    }

    component r = CalculateRootFromSiblings(nSiblings);
    for(i = 0; i < nSiblings; i++) {
        for(j = 0; j < 32; j++) {
            r.siblings[i][j] <== siblings[i][j];
        }
    }
    
    r.key <== key;

    for(i = 0; i < 32; i++) {
        r.value[i] <== h.out[i];
    }

    for(i = 0; i < 32; i++) {
        root[i] === r.root[i];
    }
}

template VerifyParentBySiblings(nSiblings) {
    signal input key;
    signal input in[32];

    signal input siblings[nSiblings][32];
    signal input root[32];

    var i;
    var j;

    component r = CalculateRootFromSiblings(nSiblings);
    for(i = 0; i < nSiblings; i++) {
        for(j = 0; j < 32; j++) {
            r.siblings[i][j] <== siblings[i][j];
        }
    }
    
    r.key <== key;

    for(i = 0; i < 32; i++) {
        r.value[i] <== in[i];
    }

    for(i = 0; i < 32; i++) {
        root[i] === r.root[i];
    }
}

component main{public[in]} = VerifyParentBySiblings(3);