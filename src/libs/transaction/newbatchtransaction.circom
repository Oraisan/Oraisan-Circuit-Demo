// SPDX-License-Identifier: GPL-3.0
pragma circom 2.0.0;

include "../Fixed_Merkle_Tree/fmtverifier.circom";
include "./newtransaction.circom";
template NewRootBatchTransaction(nTransactions, nSiblings) {
    signal input key[nTransactions];
    signal input oldValue[nTransactions];
    signal input newValue[nTransactions];
    signal input oldRoot;
    signal input siblings[nTransactions][nSiblings];
    signal output newRoot;
    
    var i;
    var j;

    component verifier[nTransactions];

    for(i = 0; i < nTransactions; i++) {
        verifier[i] = NewRootTransaction(nSiblings);
        verifier[i].key <== key[i];
        verifier[i].oldValue <== oldValue[i];
        verifier[i].oldRoot <== i == 0 ? oldRoot : verifier[i-1].newRoot;
        verifier[i].newValue <== newValue[i];
        for(j = 0; j < nSiblings; j++) {
            verifier[i].siblings[j] <== siblings[i][j];
        }
    }
    newRoot <== verifier[nTransactions - 1].newRoot;
}

template NewRootBatchTranctionWithEpoch(nEpochs, nTransactions, nSiblings) {
    assert(nTransactions % nEpochs == 0);

    var nAncestors = nTransactions/nEpochs;
    var dAncestorChild = getHeight(nEpochs);
    var ancestorsHeigh = nSiblings - dAncestorChild;

    signal input key[nTransactions];
    signal input oldValue[nTransactions];
    signal input newValue[nTransactions];
    signal input oldRoot;
    signal input siblingsAncestor[nAncestors][ancestorsHeigh];
    signal output newRoot;

    var i;
    var j;

    component oldAncestorValue[nAncestors];
    component newAncestorValue[nAncestors];

    for(i = 0; i < nAncestors; i++) {
        oldAncestorValue[i] = CalculateRootFromLeafs(nEpochs);
        newAncestorValue[i] = CalculateRootFromLeafs(nEpochs);

        for(j = 0; j < nEpochs; j++) {
            oldAncestorValue[i].in[j] <== oldValue[i * nEpochs + j];
            newAncestorValue[i].in[j] <== newValue[i * nEpochs + j];
        }
    }

    component r = NewRootBatchTransaction(nAncestors, ancestorsHeigh);
    for(i = 0; i < nAncestors; i++) {
        r.key[i] <== key[i * nEpochs] / nEpochs;
        r.oldValue[i] <== oldAncestorValue[i].out;
        r.newValue[i] <== newAncestorValue[i].out;
        for(j = 0; j < ancestorsHeigh; j++) {
            r.siblings[i][j] <== siblingsAncestor[i][j];
        }
    }    
    r.oldRoot <== oldRoot;
    newRoot <== r.newRoot;

}