// SPDX-License-Identifier: GPL-3.0
pragma circom 2.0.0;
include "avlhash.circom";
include "avlverifierlevel.circom";
include "../../../node_modules/circomlib/circuits/comparators.circom";

template CalculateRootFromSiblings(nSiblings) {
    assert(nSiblings > 0);

    signal input siblings[nSiblings][32];

    signal input key;
    signal input value[32];
    signal output root[32];
    

    component n2bNew = Num2Bits(nSiblings);
    n2bNew.in <== key;

    var i;
    var j;

    component is0[nSiblings];
    component levels[nSiblings];
    var s = 0;

    for(i=nSiblings-1; i >= 0; i--) {
        s = 0;
        for(j = 0; j < 32; j++) {
            s += siblings[i][j];
        }

        is0[i] = IsZero();
        is0[i].in <== s;

        levels[i] = AVLVerifierLevel(32);
        
        levels[i].st_top <== 1 - is0[i].out;
        levels[i].lrbit <== n2bNew.out[nSiblings - 1 - i];
        for(j = 0; j < 32; j++) {
            levels[i].sibling[j] <== siblings[i][j];
        }

        if(i == nSiblings-1) {
            for(j = 0; j < 32; j++) {
                levels[i].child[j] <== value[j];
            }
        } else {
            for(j = 0; j < 32; j++) {
                levels[i].child[j] <== levels[i+1].root[j];
            }
        }
        
    }

    for(i = 0; i < 32; i++) {
        root[i] <== levels[0].root[i];
    }
}

template CalculateRootFromLeafs(nLeafs) {
    signal input in[nLeafs][32];
    signal output out[32];
    var i;
    var j;
    
    component left;
    component right;
    component parrent;

    if(nLeafs == 1) {
        for(i = 0; i < 32; i++) {
            out[i] <== in[0][i];
        }
    } else {
        var k = getSplitPoint(nLeafs);
        left = CalculateRootFromLeafs(k);
        for(i = 0; i < k; i++) {
            for(j = 0; j < 32; j++) {
                left.in[i][j] <== in[i][j];
            }
        }

        right = CalculateRootFromLeafs(nLeafs - k);
        for(i = k; i < nLeafs; i++) {
            for(j = 0; j < 32; j++) {
                right.in[i-k][j] <== in[i][j];
            }
        }

        parrent = HashInner(32);
        log("parrent");
        for(i = 0; i < 32; i++) {
            parrent.L[i] <== left.out[i];
            parrent.R[i] <== right.out[i];
        }
        for(i = 0; i < 32; i++) {
            out[i] <== parrent.out[i];
        }
    }

}

function getSplitPoint(nLeafs) {
    var i = 1;
    for(i = 1; i * 2 < nLeafs; i *= 2) {
        
    }
    return i;
}