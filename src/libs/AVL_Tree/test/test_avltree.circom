// SPDX-License-Identifier: GPL-3.0
pragma circom 2.0.0;
include "../avlverifier.circom";
include "../../sha256/sha256standard.circom";
include "../../sha256/sha256prepared.circom";
include "../../utils/convert.circom";

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

template testHash(n) {
    signal input in1[n];
    
    component out1;
    component out2;
    out1 = Sha256Bytes(n);
    for(var i = 0; i < n; i++) {
        out1.in[i] <== in1[i];
    }

    component btb = LastBytesSHA256(8 * n);

    out2 = Sha256Prepared(1);
    for(var i = 0; i < n; i++) {
        out2.in[i] <== in1[i];
    }
    out2.in[n] <== 128;
    for(var i = n + 1; i < 56; i++) {
        out2.in[i] <== 0;
    }

    for(var i = 0; i < 8; i++) {
        out2.in[63 - i] <== btb.out[i];
    }

    for(var i = 0; i < 32; i++) {
        out1.out[i] === out2.out[i];
    }
}
component main = testHash(2);