pragma circom 2.0.0;

include "fieldsencode.circom";

template MsgHeaderEncodeToBits(nMsgBytes) {
    // var nType = 8;
    var nHeight = 64;
    var nHash = 256;
    var nParts = 1;
    var nTotal = 8;
    var nSeconds = 40;
    var nNanos = 40;
    // var nChainID = 9; 
    
    var prefixType = 8;
    var prefixHeight = 17;
    var prefixBlockID = 34;
    var prefixBlockHash = 10;
    var prefixParts = 18;
    var prefixPartsTotal = 8;
    var prefixPartsHash = 18;
    var prefixTimestamp = 42;
    var prefixSeconds = 8;
    var prefixNanos = 16;
    var prefixChainID = 50;

    var i;
    var j;
    var idx;

    signal input fnc;

    signal input height;
    signal input blockHash[nHash];
    signal input partsTotal;
    signal input partsHash[nParts][nHash];
    signal input seconds;
    signal input nanos;
    // signal input chainID[nChainID];
    signal input msg[nMsgBytes];

    // prefix = 0x32
    // len = 0x09
    // chaiID = Oraichain
    var chainID[88] = [ 
                        0, 1, 0, 0, 1, 1, 0, 0,    
                        1, 0, 0, 1, 0, 0, 0, 0, 
                        1, 1, 1, 1, 0, 0, 1, 0, 
                        0, 1, 0, 0, 1, 1, 1, 0, 
                        1, 0, 0, 0, 0, 1, 1, 0, 
                        1, 0, 0, 1, 0, 1, 1, 0, 
                        1, 1, 0, 0, 0, 1, 1, 0, 
                        0, 0, 0, 1, 0, 1, 1, 0, 
                        1, 0, 0, 0, 0, 1, 1, 0, 
                        1, 0, 0, 1, 0, 1, 1, 0,  
                        0, 1, 1, 1, 0, 1, 1, 0
                    ];
    
    // EncodeLengthMsg(8)
    // len = 110
    var eLengthMsg[8] = [0, 1, 1, 1, 0, 1, 1, 0];

    // EncodeType(prefixType, nType);
    // type = 2
    var eType[16] = [
                        0, 0, 0, 1, 0, 0, 0, 0, 
                        0, 1, 0, 0, 0, 0, 0, 0
                    ];

    component eHeight = EncodeHeightToBits(prefixHeight, nHeight);
    eHeight.height <== height;

    component eBlockID = EncodeBlockIDToBits(prefixBlockID, prefixBlockHash, prefixParts, prefixPartsHash, prefixPartsTotal);
    for(i = 0; i < nHash; i++) {
            eBlockID.blockHash[i] <== blockHash[i];
    }

    eBlockID.partsTotal <== partsTotal;
    for(i = 0; i < nParts; i++) {
        for(j = 0; j < nHash; j++) {
            eBlockID.partsHash[i][j] <== partsHash[i][j];
        }
    }

    component eTimestamp = EncodeTimestampToBits(prefixTimestamp, prefixSeconds, prefixNanos);
    eTimestamp.seconds <== seconds;
    eTimestamp.nanos <== nanos;

    for(i = 0; i < 8; i++) {
        msg[i] === eLengthMsg[i] * fnc;
    }

    for(i = 0; i < 16; i++) {
        msg[i + 8] === eType[i] * fnc;
    }

    idx = 24;
    for(i = 0; i < 8 + nHeight; i++) {
        msg[i + idx] === eHeight.out[i] * fnc;
    }
    idx += 8 + nHeight;

    for(i = 0; i < 16 + nHash + 16 + nParts * (nHash + nTotal + 40); i++) {
        msg[i +idx] === eBlockID.out[i] * fnc;
    }
    idx += 16 + nHash + 16 + nParts * (nHash + nTotal + 40);

    for(i = 0; i < 32 + nSeconds + nNanos; i++) {
        msg[i + idx] === eTimestamp.out[i] * fnc;
    }
    idx += 32 + nSeconds + nNanos;

    for(i = 0; i < 88; i++) {
        msg[i + idx] === chainID[i] * fnc;
    }
}

template MsgHeaderEncodeToBytes(nMsgBytes) {
    // var nType = 8;
    var nHeight = 8;
    var nHash = 32;
    var nParts = 1;
    var nTotal = 1;
    var nSeconds = 5;
    var nNanos = 5;
    // var nChainID = 9; 
    
    var prefixType = 8;
    var prefixHeight = 17;
    var prefixBlockID = 34;
    var prefixBlockHash = 10;
    var prefixParts = 18;
    var prefixPartsTotal = 8;
    var prefixPartsHash = 18;
    var prefixTimestamp = 42;
    var prefixSeconds = 8;
    var prefixNanos = 16;
    var prefixChainID = 50;

    var i;
    var j;
    var idx;

    signal input fnc;
   
    signal input height;
    signal input blockHash[nHash];
    signal input partsTotal;
    signal input partsHash[nParts][nHash];
    signal input seconds;
    signal input nanos;
    // signal input chainID[nChainID];
    signal input msg[nMsgBytes];

    // prefix = 0x32
    // len = 0x09
    // chaiID = Oraichain
    // EncodeLengthMsg(8)
    // len = 110
    var eLengthMsg = 110;
    msg[0] === eLengthMsg * fnc;
    
    var chainID[11] = [50, 9, 79, 114, 97, 105, 99, 104, 97, 105, 110];
    // EncodeType(prefixType, nType);
    // type = 2
    var eType[2] = [prefixType, 2];
    msg[1] === eType[0] * fnc;
    msg[2] === eType[1] * fnc;

    component eHeight = EncodeHeightToBytes(prefixHeight, nHeight);
    eHeight.height <== height;

    component eBlockID = EncodeBlockIDToBytes(prefixBlockID, prefixBlockHash, prefixParts, prefixPartsHash, prefixPartsTotal);
    for(i = 0; i < nHash; i++) {
            eBlockID.blockHash[i] <== blockHash[i];
    }

    eBlockID.partsTotal <== partsTotal;
    for(i = 0; i < nParts; i++) {
        for(j = 0; j < nHash; j++) {
            eBlockID.partsHash[i][j] <== partsHash[i][j];
        }
    }

    component eTimestamp = EncodeTimestampToBytes(prefixTimestamp, prefixSeconds, prefixNanos);
    eTimestamp.seconds <== seconds;
    eTimestamp.nanos <== nanos;

    idx = 3;
    for(i = 0; i < 1 + nHeight; i++) {
        msg[i + idx] === eHeight.out[i] * fnc;
    }
    idx += 1 + nHeight;

    for(i = 0; i < 2 + nHash + 2 + nParts * (nHash + 2) + nTotal + 3; i++) {
        // log(i + idx, msg[i+idx], eBlockID.out[i]);
        msg[i +idx] === eBlockID.out[i] * fnc;
    }
    idx += 2 + nHash + 2 + nParts * (nHash + 2) + nTotal + 3;

    for(i = 0; i < 4 + nSeconds + nNanos; i++) {
        msg[i + idx] === eTimestamp.out[i] * fnc;
    }
    idx += 4 + nSeconds + nNanos;

    for(i = 0; i < 11; i++) {
        msg[i + idx] === chainID[i] * fnc;
    }
    idx + 11 === nMsgBytes;
}

template MsgHeaderEncodeWithoutTimestampToBytes(nMsgBytes) {
    // var nType = 8;
    var nHeight = 8;
    var nHash = 32;
    var nParts = 1;
    var nTotal = 1;
    var nSeconds = 5;
    var nNanos = 5;
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

    signal input height;
    signal input blockHash[nHash];
    signal input partsTotal;
    signal input partsHash[nParts][nHash];
    // signal input chainID[nChainID];
    signal output msg[nMsgBytes];

    // prefix = 0x32
    // len = 0x09
    // chaiID = Oraichain
    // EncodeLengthMsg(8)
    // len = 110
    var eLengthMsg = 110;
    msg[0] <== eLengthMsg;
    
    var chainID[11] = [50, 9, 79, 114, 97, 105, 99, 104, 97, 105, 110];
    // EncodeType(prefixType, nType);
    // type = 2
    var eType[2] = [prefixType, 2];
    msg[1] <== eType[0];
    msg[2] <== eType[1];

    component eHeight = EncodeHeightToBytes(prefixHeight, nHeight);
    eHeight.height <== height;

    component eBlockID = EncodeBlockIDToBytes(prefixBlockID, prefixBlockHash, prefixParts, prefixPartsHash, prefixPartsTotal);
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

    for(i = 0; i < 11; i++) {
        msg[i + idx] <== chainID[i];
    }
    idx + 11 === nMsgBytes;
}

