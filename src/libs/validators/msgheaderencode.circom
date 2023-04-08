pragma circom 2.0.0;

include "../utils/filedsmsgheaderencode.circom";

template MsgEncode(nChainID, nSeconds, nNanos) {
    var nParts = 1;
    var prefixTimestamp = 42;
    var prefixSeconds = 8;
    var prefixNanos = 16;
    var nMsgBytes = 92 + nChainID + nSeconds + nNanos;

    var i;
    var j;
    var idx;

    signal input type;
    signal input chainID[nChainID];
    signal input height;
    signal input blockHash[32];
    signal input partsTotal;
    signal input partsHash[nParts][32];
    signal input seconds;
    signal input nanos;
    // signal input chainID[nChainID];
    signal output out[nMsgBytes];

    component mheWT = MsgHeaderEncodeWithoutTimestamp(nMsgBytes, nChainID, nSeconds, nNanos);        
    mheWT.type <== type;

    for(j = 0; j < nChainID; j++) {
        mheWT.chainID[j] <== chainID[j];
    }

    mheWT.height <== height;
    for(j = 0; j < 32; j++) {
        mheWT.blockHash[j] <== blockHash[j];
        for(var k = 0; k < nParts; k++) {
            mheWT.partsHash[k][j] <== partsHash[k][j];
        }
    }
    mheWT.partsTotal <== partsTotal;

    for(j = 0; j < nMsgBytes - nSeconds - nNanos - nChainID - 6; j++) {
            out[j] <== mheWT.msg[j];
    }

    component mhe = EncodeTimestamp(prefixTimestamp, prefixSeconds, prefixNanos, nSeconds, nNanos);
    mhe.seconds <== seconds;
    mhe.nanos <== nanos;
        
    idx = nMsgBytes - nSeconds - nNanos - nChainID - 6;
    for(j = 0; j < nNanos + nSeconds + 4; j++) {
        out[j + idx] <== mhe.out[j];
    }

    idx += nSeconds + nNanos + 4;
    for(j = 0; j < nChainID + 2; j++) {
        out[j+idx] <== mheWT.msg[j+idx];
    }
    
}

template MsgHeaderEncodeWithoutTimestamp(nMsgBytes, nChainID, nSeconds, nNanos) {
    var nHeight = 8;
    var nHash = 32;
    var nParts = 1;
    var nTotal = 1;
    // var nSeconds = 5;
    // var nNanos = 5;
    // var nChainID = 9; 
    
    var prefixType = 8;
    var prefixHeight = 17;
    var prefixBlockID = 34;
    var prefixBlockHash = 10;
    var prefixParts = 18;
    var prefixPartsTotal = 8;
    var prefixPartsHash = 18;
    var prefixChainID = 50;

    var i;
    var j;
    var idx;

    signal input type;
    signal input chainID[nChainID];
    signal input height;
    signal input blockHash[nHash];
    signal input partsTotal;
    signal input partsHash[nParts][nHash];
    signal output msg[nMsgBytes];

    // EncodeLengthMsg(8)
    // len = 110
    msg[0] <== nMsgBytes - 1;
    msg[1] <== prefixType;
    msg[2] <== type;

    component eHeight = EncodeHeight(prefixHeight, nHeight);
    eHeight.height <== height;

    component eBlockID = EncodeBlockID(prefixBlockID, prefixBlockHash, prefixParts, prefixPartsHash, prefixPartsTotal);
    for(i = 0; i < nHash; i++) {
            eBlockID.blockHash[i] <== blockHash[i];
    }

    eBlockID.partsTotal <== partsTotal;
    for(i = 0; i < nParts; i++) {
        for(j = 0; j < nHash; j++) {
            eBlockID.partsHash[i][j] <== partsHash[i][j];
        }
    }

    idx = 3;
    for(i = 0; i < 1 + nHeight; i++) {
        msg[i + idx] <== eHeight.out[i];
    }
    idx += 1 + nHeight;

    for(i = 0; i < 2 + nHash + 2 + nParts * (nHash + 2) + nTotal + 3; i++) {
        // log(i + idx, msg[i+idx], eBlockID.out[i]);
        msg[i +idx] <== eBlockID.out[i];
    }
    idx += 2 + nHash + 2 + nParts * (nHash + 2) + nTotal + 3;

    for(i = 0; i < 4 + nSeconds + nNanos; i++) {
        msg[i + idx] <== 0;
    }
    idx += 4 + nSeconds + nNanos;

    msg[idx] <== prefixChainID;
    msg[idx + 1] <== nChainID;
    for(i = 0; i < 9; i++) {
        msg[i + idx + 2] <== chainID[i];
    }
    idx + 11 === nMsgBytes;
}

