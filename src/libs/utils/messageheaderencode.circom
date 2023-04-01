pragma circom 2.0.0;

include "fieldsencode.circom";

template MessageHeaderEncodeToBits(nMsg) {
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

    signal input height;
    signal input blockHash[nHash];
    signal input partsTotal;
    signal input partsHash[nParts][nHash];
    signal input seconds;
    signal input nanos;
    // signal input chainID[nChainID];
    signal input message[nMsg];

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

    idx = 24;
    for(i = 0; i < 8 + nHeight; i++) {
        message[i + idx] === eHeight.out[i];
    }
    idx += 8 + nHeight;

    for(i = 0; i < 16 + nHash + 16 + nParts * (nHash + nTotal + 40); i++) {
        message[i +idx] === eBlockID.out[i];
    }
    idx += 16 + nHash + 16 + nParts * (nHash + nTotal + 40);

    for(i = 0; i < 32 + nSeconds + nNanos; i++) {
        message[i + idx] === eTimestamp.out[i];
    }
}

template MessageHeaderEncodeToBytes(nMsg) {
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

    signal input height;
    signal input blockHash[nHash];
    signal input partsTotal;
    signal input partsHash[nParts][nHash];
    signal input seconds;
    signal input nanos;
    // signal input chainID[nChainID];
    signal input message[nMsg];

    // prefix = 0x32
    // len = 0x09
    // chaiID = Oraichain
    // EncodeLengthMsg(8)
    // len = 110
    var eLengthMsg = 110;
    message[0] === eLengthMsg;
    
    var chainID[11] = [50, 9, 79, 114, 97, 105, 99, 104, 97, 105, 110];
    // EncodeType(prefixType, nType);
    // type = 2
    var eType[2] = [prefixType, 2];
    message[1] === eType[0];
    message[2] === eType[1];

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
        message[i + idx] === eHeight.out[i];
    }
    idx += 1 + nHeight;

    for(i = 0; i < 2 + nHash + 2 + nParts * (nHash + 2) + nTotal + 3; i++) {
        // log(i + idx, message[i+idx], eBlockID.out[i]);
        message[i +idx] === eBlockID.out[i];
    }
    idx += 2 + nHash + 2 + nParts * (nHash + 2) + nTotal + 3;

    for(i = 0; i < 4 + nSeconds + nNanos; i++) {
        message[i + idx] === eTimestamp.out[i];
    }
    idx += 4 + nSeconds + nNanos;

    for(i = 0; i < 11; i++) {
        message[i + idx] === chainID[i];
    }
    idx + 11 === nMsg;
}