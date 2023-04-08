pragma circom 2.0.0;

include "../utils/filedsmsgheaderencode.circom";

template MsgEncode(nChainID, nSeconds, nNanos) {
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
    signal input partsHash[32];
    signal input seconds;
    signal input nanos;
    // signal input chainID[nChainID];
    signal output out[nMsgBytes];

    component mheWT = MsgHeaderEncodeWithoutTimestamp(nMsgBytes, nChainID, nSeconds, nNanos);        
    mheWT.type <== type;

    for(i = 0; i < nChainID; i++) {
        mheWT.chainID[i] <== chainID[i];
    }

    mheWT.height <== height;
    for(i = 0; i < 32; i++) {
        mheWT.blockHash[i] <== blockHash[i];
        mheWT.partsHash[i] <== partsHash[i];
        
    }
    mheWT.partsTotal <== partsTotal;

    for(i = 0; i < nMsgBytes - nSeconds - nNanos - nChainID - 6; i++) {
            out[i] <== mheWT.msg[i];
    }

    component mhe = EncodeTimestamp(prefixTimestamp, prefixSeconds, prefixNanos, nSeconds, nNanos);
    mhe.seconds <== seconds;
    mhe.nanos <== nanos;
        
    idx = nMsgBytes - nSeconds - nNanos - nChainID - 6;
    for(i = 0; i < nNanos + nSeconds + 4; i++) {
        out[i + idx] <== mhe.out[i];
    }

    idx += nSeconds + nNanos + 4;
    for(i = 0; i < nChainID + 2; i++) {
        out[i + idx] <== mheWT.msg[i + idx];
    }
    
}

template MsgHeaderEncodeWithoutTimestamp(nMsgBytes, nChainID, nSeconds, nNanos) {
    var nHeight = 8;

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
    signal input blockHash[32];
    signal input partsTotal;
    signal input partsHash[32];
    signal output msg[nMsgBytes];

    // EncodeLengthMsg(8)
    // len = 110
    msg[0] <== nMsgBytes - 1;
    msg[1] <== prefixType;
    msg[2] <== type;

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
    

    idx = 3;
    for(i = 0; i < 1 + nHeight; i++) {
        msg[i + idx] <== eHeight.out[i];
    }
    idx += 1 + nHeight;

    for(i = 0; i < 74; i++) {
        msg[i +idx] <== eBlockID.out[i];
    }
    idx += 74;

    for(i = 0; i < 4 + nSeconds + nNanos; i++) {
        msg[i + idx] <== 0;
    }
    idx += 4 + nSeconds + nNanos;

    msg[idx] <== prefixChainID;
    msg[idx + 1] <== nChainID;

    for(i = 0; i < nChainID; i++) {
        msg[i + idx + 2] <== chainID[i];
    }
    idx + 11 === nMsgBytes;
}

