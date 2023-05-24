// SPDX-License-Identifier: GPL-3.0
pragma circom 2.0.0;
include "../../libs/transaction/newbatchtransaction.circom";

template VerifyBatchTransaction(nTransaction, nSiblings) {
    signal input key[nTransaction];
    signal input newValue[nTransaction];
    signal input oldRoot;
    signal input siblings[nTransaction][nSiblings];
    signal input newRoot;
    var i;
    var j;

    var oldValue = 11730251359286723731141466095709901450170369094578288842486979042586033922425;
    component r = NewRootBatchTransaction(nTransaction, nSiblings);
    r.oldRoot <== oldRoot;
    for(i = 0; i < nTransaction; i++) {
        r.key[i] <== key[i];
        r.oldValue[i] <== oldValue;
        r.newValue[i] <== newValue[i];
        for(j = 0; j < nSiblings; j++) {
            r.siblings[i][j] <== siblings[i][j];
        }
    }
    newRoot === r.newRoot;
}
component main{public[key, newValue, oldRoot, newRoot]} = VerifyBatchTransaction(4, 32);
