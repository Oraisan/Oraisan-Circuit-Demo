// SPDX-License-Identifier: GPL-3.0
pragma circom 2.0.0;
include "../utils/msgheaderencode.circom";
include "../utils/fieldsencode.circom";

template MsgEncodeVerifierByBytes(nMsgBytes, nValidator) {
    var nParts = 1;
    var nSeconds = 5;
    var nNanos = 5;
    var nChainID = 9;
    
    var prefixTimestamp = 42;
    var prefixSeconds = 8;
    var prefixNanos = 16;

    var i;
    var j;
    var idx;

    signal input fnc[nValidator];
    
    signal input height;
    signal input blockHash[32];
    signal input partsTotal;
    signal input partsHash[nParts][32];
    signal input seconds[nValidator];
    signal input nanos[nValidator];
    // signal input chainID[nChainID];
    signal input msg[nValidator][nMsgBytes];

    component mheWT = MsgHeaderEncodeWithoutTimestampToBytes(nMsgBytes);        
    mheWT.height <== height;
    for(j = 0; j < 32; j++) {
        mheWT.blockHash[j] <== blockHash[j];
        for(var k = 0; k < nParts; k++) {
            mheWT.partsHash[k][j] <== partsHash[k][j];
        }
    }
    mheWT.partsTotal <== partsTotal;

    component mhe[nValidator];

    for(i = 0; i < nValidator; i++) {
        
        for(j = 0; j < nMsgBytes - nSeconds - nNanos - nChainID - 6; j++) {
            msg[i][j] === mheWT.msg[j] * fnc[i];
        }

        mhe[i] = EncodeTimestampToBytes(prefixTimestamp, prefixSeconds, prefixNanos);
        mhe[i].seconds <== seconds[i];
        mhe[i].nanos <== nanos[i];
        
        idx = nMsgBytes - nSeconds - nNanos - nChainID - 6;
        for(j = 0; j < nNanos + nSeconds + 4; j++) {
            msg[i][j + idx] === mhe[i].out[j] * fnc[i];
        }

        idx += nSeconds + nNanos + 4;
        for(j = 0; j < nChainID + 2; j++) {
            msg[i][j+idx] === mheWT.msg[j+idx] * fnc[i];
        }
    }
}