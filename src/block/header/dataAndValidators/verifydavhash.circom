// SPDX-License-Identifier: GPL-3.0
pragma circom 2.0.0;
include "../../../libs/AVL_Tree/avlhash.circom";
include "../../../libs/AVL_Tree/avlverifier.circom";
include "../../../libs/block/hashblockelements.circom";


template VerifyDAVHash() {
    var prefixBytes = 10;
    signal input dataHash[32];
    signal input validatorsHash[32];
    signal input parrentSiblings[3][32];
    signal input blockHash[32];

    var i;
    var j;
    component dataHashLeaf = HashBytesElemnt(prefixBytes, 32);
    for(i = 0; i < 32; i++) {
        dataHashLeaf.in[i] <== dataHash[i];
    }

    component validatorsHashLeaf = HashBytesElemnt(prefixBytes, 32);
    for(i = 0; i < 32; i++) {
        validatorsHashLeaf.in[i] <== validatorsHash[i];
    }

    component parrent = HashInner(32);
    for(i = 0; i < 32; i++) {
        parrent.L[i] <== dataHashLeaf.out[i];
        parrent.R[i] <== validatorsHashLeaf.out[i];
    }

    component root = CalculateRootFromSiblings(3);
    for(i = 0; i < 3; i++) {
        for(j = 0; j < 32; j++) {
            root.siblings[i][j] <== parrentSiblings[2-i][j];
        }
    }
    
    root.key <== 3;

    for(i = 0; i < 32; i++) {
        root.value[i] <== parrent.out[i];
    }

    for(i = 0; i < 32; i++) {
        blockHash[i] === root.root[i];
    }

}
component main{public[dataHash, validatorsHash, blockHash]} = VerifyDAVHash();