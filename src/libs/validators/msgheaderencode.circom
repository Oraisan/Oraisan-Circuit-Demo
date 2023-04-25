// SPDX-License-Identifier: GPL-3.0
pragma circom 2.0.0;

include "../utils/filedsmsgheaderencode.circom";
include "../utils/shiftbytes.circom";

template MsgEncode(nChainID) {
    var prefixTimestamp = 42;
    var prefixSeconds = 8;
    var prefixNanos = 16;
    var prefixChainID = 50;
    var nMsgBytes = 102 + nChainID;

    var i;
    var j;
    var idx;

    signal input type;
    signal input chainID[nChainID];
    signal input height;
    signal input blockHash[32];
    signal input partsTotal;
    signal input partsHash[32];
    signal input seconds;
    signal input nanos;
    signal output out[nMsgBytes];
    signal output length;
    
    // encode the fields before timestamp and chainID 
    component mheWT = MsgHeaderEncodeBeforeTimestamp(85);        
    mheWT.type <== type;

    mheWT.height <== height;
    for(i = 0; i < 32; i++) {
        mheWT.blockHash[i] <== blockHash[i];
        mheWT.partsHash[i] <== partsHash[i];
        
    }
    mheWT.partsTotal <== partsTotal;

    // encode timestamp
    component mhe = EncodeTimestamp(prefixTimestamp, prefixSeconds, prefixNanos);
    mhe.seconds <== seconds;
    mhe.nanos <== nanos;
    
    //because of timestamp has length range from 0 to 10 bytes so i need process it before use sha512 
    component putIDOnTop = PutBytesOnTop(14, nChainID + 2);
    for(i = 0; i < 14; i++) {
        putIDOnTop.s1[i] <== mhe.out[i];
    }
    
    putIDOnTop.idx <== mhe.length;


    putIDOnTop.s2[0] <== prefixChainID;
    putIDOnTop.s2[1] <== nChainID;
    for(i = 0; i < nChainID; i++) {
        putIDOnTop.s2[i + 2] <== chainID[i];
    }

    //output
    // output length
    out[0] <== 87 + mhe.length + nChainID;

    //output fields encoded before timestamp and chainID
    for(i = 0; i < 85; i++) {
            out[i + 1] <== mheWT.msg[i];
    }
    
    //output timestamp and chainID encoded
    for(i = 0; i < 14 + nChainID + 2; i++) {
        out[i + 86] <== putIDOnTop.out[i];
    }

    //output msg length
    length <== 88 + mhe.length + nChainID;

}

template MsgHeaderEncodeBeforeTimestamp(nMsgBytes) {
    var nHeight = 8;

    var prefixType = 8;
    var prefixHeight = 17;
    var prefixBlockID = 34;
    var prefixBlockHash = 10;
    var prefixParts = 18;
    var prefixPartsTotal = 8;
    var prefixPartsHash = 18;
    // var prefixChainID = 50;

    var i;
    var j;
    var idx;

    signal input type;
    signal input height;
    signal input blockHash[32];
    signal input partsTotal;
    signal input partsHash[32];
    signal output msg[nMsgBytes];

    msg[0] <== prefixType;
    msg[1] <== type;

    component eHeight = EncodeHeight(prefixHeight, nHeight);
    eHeight.height <== height;

    component eBlockID = EncodeBlockID(prefixBlockID, prefixBlockHash, prefixParts, prefixPartsHash, prefixPartsTotal);
    for(i = 0; i < 32; i++) {
            eBlockID.blockHash[i] <== blockHash[i];
    }

    eBlockID.partsTotal <== partsTotal;
    for(i = 0; i < 32; i++) {
        eBlockID.partsHash[i] <== partsHash[i];
    }
    

    idx = 2;
    for(i = 0; i < 1 + nHeight; i++) {
        msg[i + idx] <== eHeight.out[i];
    }
    idx += 1 + nHeight;

    for(i = 0; i < 74; i++) {
        msg[i +idx] <== eBlockID.out[i];
    }
    idx += 74;
}

