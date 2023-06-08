// SPDX-License-Identifier: GPL-3.0
pragma circom 2.0.0;
include "../newbatchtransaction.circom";

template VerifyRootDepositVerifier(nTransaction, nSiblings) {
    var nBytesAuthInfoMarshal = getLengthAuthInfoMarshal(); //109
    var nBytesSignatureMarshal = getLengthSignturesMarshal(); //66
    var nBytesTx = nBytesBodyMarshal + nBytesAuthInfoMarshal + nBytesSignatureMarshal;
    signal input txBody[nBytesBodyMarshal];
    signal input txAuthInfos[nBytesAuthInfoMarshal];
    signal input signatures[nBytesSignatureMarshal];
    

    component te = CalcuteTransactionDefaultHash(nBytesBodyMarshal);
    for(i = 0; i < nBytesBodyMarshal; i++) {
        te.txBody[i] <== txBody[i];
    }

    for(i = 0; i < nBytesAuthInfoMarshal; i++) {
        te.txAuthInfos[i] <== txAuthInfos[i];
    }

    for(i = 0; i < nBytesSignatureMarshal; i++) {
        te.signatures[i] <== signatures[i];
    }
}
component main = VerifyRootDepositVerifier(922);
