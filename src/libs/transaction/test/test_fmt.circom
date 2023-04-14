// SPDX-License-Identifier: GPL-3.0
pragma circom 2.0.0;
include "../newbatchtransaction.circom";

template VerifyNewRootBatchTransaction(nTransaction, nSiblings) {
    signal input key[nTransaction];
    signal input oldValue[nTransaction];
    signal input newValue[nTransaction];
    signal input oldRoot;
    signal input siblings[nTransaction][nSiblings];
    signal input newRoot;
    var i;
    var j;

    component r =NewRootBatchTransaction(nTransaction, nSiblings);
    r.oldRoot <== oldRoot;
    for(i = 0; i < nTransaction; i++) {
        r.key[i] <== key[i];
        r.oldValue[i] <== oldValue[i];
        r.newValue[i] <== newValue[i];
        for(j = 0; j < nSiblings; j++) {
            r.siblings[i][j] <== siblings[i][j];
        }
    }
    newRoot === r.newRoot;
}
component main = NewRootBatchTranctionWithEpoch(4, 20, 32);
