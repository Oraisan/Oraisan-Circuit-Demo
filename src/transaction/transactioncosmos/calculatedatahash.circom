// SPDX-License-Identifier: GPL-3.0
pragma circom 2.0.0;
include "./calculatetransactionhash.circom";
include "../../libs/AVL_Tree/avlverifier.circom";
include "../../libs/AVL_Tree/avlhash.circom";

template CalculateDataHashFromTxData(nSiblings, nBytesBodyMarshal) {
    var nBytesAuthInfoMarshal = getLengthAuthInfoMarshal(); //109
    var nBytesSignatureMarshal = getLengthSignturesMarshal(); //66

    signal input txBody[nBytesBodyMarshal];
    signal input txAuthInfos[nBytesAuthInfoMarshal];
    signal input signatures[nBytesSignatureMarshal];

    signal input key;
    signal input siblings[nSiblings][32];
    
    signal output out[32];

    var i;
    var j;

    component value = CalcuteTransactionDefaultHash(nBytesBodyMarshal);
    for(i = 0; i < nBytesBodyMarshal; i++) {
        value.txBody[i] <== txBody[i];
    }

    for(i = 0; i < nBytesAuthInfoMarshal; i++) {
        value.txAuthInfos[i] <== txAuthInfos[i];
    }

    for(i = 0; i < nBytesSignatureMarshal; i++) {
        value.signatures[i] <== signatures[i];
    }
    
    // for(i = 0; i < 32; i++) {
    //     log(i, value.out[i]);
    // }
    component leafs = HashLeaf(32);
    for(i = 0; i < 32; i++) {
        leafs.in[i] <== value.out[i];
    }

    component r = CalculateRootFromSiblings(nSiblings);
    for(j = 0; j < 32; j++) {
        for(i = 0; i < nSiblings; i++) {
            r.siblings[i][j] <== siblings[i][j];
        }
        r.value[j] <== leafs.out[j];
    }
    r.key <== key;
    

    for(i = 0; i < 32; i++) {
        out[i] <== r.root[i];
    }
}