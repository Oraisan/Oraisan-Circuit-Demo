// SPDX-License-Identifier: GPL-3.0
pragma circom 2.0.0;

include "../../../libs/utils/address.circom";
include "../../../libs/transaction/txData/encodetx.circom";
include "../../../libs/transaction/txData/encodeTxAuthInfo/txauthinfoencode.circom";
include "../../../libs/transaction/txData/encodeTxBody/txbodyencode.circom";
include "../../../libs/transaction/calculatedatahash.circom";

template RootDepositVerifier(nSiblings, nBytesBodyMarshal) {

    var nBytesAuthInfoMarshal = getLengthAuthInfoMarshal(); //109
    var nBytesSignatureMarshal = getLengthSignturesMarshal(); //66

    signal input txBody[nBytesBodyMarshal];
    signal input txAuthInfos[nBytesAuthInfoMarshal];
    signal input signatures[nBytesSignatureMarshal];

    signal input key;
    signal input dataHash[32];
    signal input siblings[nSiblings][32];

    signal output sender;
    signal output contract;
    signal output depositRoot;
    signal output dataHashAddress;

    var i;
    var j;

    component te = CalculateDataHashFromTxData(nSiblings, nBytesBodyMarshal);
    for(i = 0; i < nBytesBodyMarshal; i++) {
        te.txBody[i] <== txBody[i];
    }

    for(i = 0; i < nBytesAuthInfoMarshal; i++) {
        te.txAuthInfos[i] <== txAuthInfos[i];
    }

    for(i = 0; i < nBytesSignatureMarshal; i++) {
        te.signatures[i] <== signatures[i];
    }
    
    te.key <== key;
    for(i = 0; i < nSiblings; i++) {
        for(j = 0; j < 32; j++) {
            te.siblings[i][j] <== siblings[i][j];
        }
    }


    for(i = 0; i < 32; i++) {
        te.out[i] === dataHash[i];
    }


    // component da = CalculateAddress();
    // for(i = 0; i < 32; i++) {
    //     da.in[i] <== dataHash[i];
    // }

    // component eb = ExtractBody(nBytesBodyMarshal);
    // for(i = 0; i < nBytesBodyMarshal; i++) {
    //     eb.in[i] <== txBody[i];
    // }

    // // log("sender", eb.sender);
    // // log("contract", eb.contract);
    // // log("depositRoot", eb.depositRoot);

    // sender <== eb.sender;
    // contract <== eb.contract;
    // depositRoot <== eb.depositRoot;

    // dataHashAddress <== da.out;
}
component main = RootDepositVerifier(2, 922);