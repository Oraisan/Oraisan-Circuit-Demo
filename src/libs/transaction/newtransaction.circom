// SPDX-License-Identifier: GPL-3.0
pragma circom 2.0.0;

include "../Fixed_Merkle_Tree/fmtverifier.circom";

template NewRootTransaction(nSiblings) {
    signal input key;
    signal input oldValue;
    signal input oldRoot;
    signal input newValue;
    signal input siblings[nSiblings];
    signal output newRoot;
    
    var i;

    component vOld = CalculateRootFromSiblings(nSiblings);
    vOld.key <== key;
    vOld.in <== oldValue;
    for(i = 0; i < nSiblings; i++) {
        vOld.siblings[i] <== siblings[i];
    }
    vOld.root === oldRoot;

    component vNew = CalculateRootFromSiblings(nSiblings);
    vNew.key <== key;
    vNew.in <== newValue;
    for(i = 0; i < nSiblings; i++) {
        vNew.siblings[i] <== siblings[i];
    }
    newRoot <== vNew.root;
}