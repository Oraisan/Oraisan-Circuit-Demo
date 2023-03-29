// SPDX-License-Identifier: GPL-3.0
pragma circom 2.0.0;
include "avlhash.circom";
include "avlverifierlevel.circom";
include "../../../node_modules/circomlib/circuits/comparators.circom";

template AVLVerifier(nLevels, nBytes) {
    signal input root[nBytes];
    signal input siblings[nLevels][nBytes];

    signal input key;
    signal input value[nBytes];
    

    component n2bNew = Num2Bits(nLevels);
    n2bNew.in <== key;

    var i;
    var j;

    // component leaf = HashLeaf(nBytes);
    // for(i = 0; i <nBytes; i++) {
    //     leaf.leaf[i] <== valueBits[i];
    // } 

    // for(i = 0; i < nBytes; i++) {
    //     leaf.out[i] === root[i];
    // }
    component is0[nLevels];
    component levels[nLevels];
    var s = 0;

    component testHash = HashInner(nBytes);
    for(i=nLevels-1; i >= 0; i--) {
        s = 0;
        for(j = 0; j < nBytes; j++) {
            s += siblings[i][j];
        }

        is0[i] = IsZero();
        is0[i].in <== s;

        levels[i] = AVLVerifierLevel(nBytes);
        
        levels[i].st_top <== is0[i].out;
        levels[i].lrbit <== n2bNew.out[i];
        for(j = 0; j < nBytes; j++) {
            levels[i].sibling[j] <== siblings[i][j];
        }

        if(i == nLevels-1) {
            for(j = 0; j < nBytes; j++) {
                levels[i].child[j] <== 0;
            }
        } else {
            for(j = 0; j < nBytes; j++) {
                levels[i].child[j] <== levels[i+1].root[j];
            }
        }
        
    }

    // for(i = 0; i <nBytes; i++) {
    //     levels[0].root[i] === root[i];
    // }
}

component main{public[value]} = AVLVerifier(2, 32);