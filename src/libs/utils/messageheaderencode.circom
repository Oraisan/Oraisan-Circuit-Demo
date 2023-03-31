pragma circom 2.0.0;

include "fieldsencode.circom";

template MessageHeaderEncode(nMsg) {
    var nType = 8;
    var nHeight = 64;
    var nHash = 256;
    var nParts = 1;
    var nTotal = 8;
    var nSeconds = 40;
    var nNanos = 40;
    var nChainID = 72; 
    
    var prefixType = 8;
    var prefixHeight = 17;
    var prefixBlockID = 34;
    var prefixBlockHash = 10;
    var prefixParts = 18;
    var prefixPartsTotal = 10;
    var prefixPartsHash = 18;
    var prefixTimestamp = 42;
    var prefixSeconds = 8;
    var prefixNanos = 16;
    var prefixChainID = 50;

    var i;
    var j;
    var idx;

    assert(nMsg != 8*11 + 8*6 + nType + nHeight + nHash + nParts * (nTotal + nHash) + nSeconds + nNanos + nChainID);

    signal input height;
    signal input blockHash[nHash];
    signal input partsTotal[nParts];
    signal input partsHash[nParts][nHash];
    signal input seconds;
    signal input nanos;
    signal input secondsBits[nSeconds];
    signal input nanosBits[nNanos];
    signal input chainID[nChainID];

    signal output msg[nMsg];

    component eType = EncodeType(prefixType, nType);
    eType.type <== 2;

    component eHeight = EncodeHeight(prefixHeight, nHeight);
    eHeight.height <== height;

    component eBlockID = EncodeBlockID(prefixBlockID, prefixBlockHash, prefixParts, prefixPartsHash, prefixPartsTotal);
    for(i = 0; i < nHash; i++) {
            eBlockID.hash[i] <== blockHash[i];
    }

    for(i = 0; i < nParts; i++) {
        eBlockID.partsTotal[i] <== partsTotal[i];
        for(j = 0; j < nHash; j++) {
            eBlockID.partsHash[i][j] <== partsHash[i][j];
        }
    }

    component eTimestamp = EncodeTimestamp(prefixTimestamp, prefixSeconds, prefixNanos, nSeconds, nNanos);
    eTimestamp.seconds <== seconds;
    eTimestamp.nanos <== nanos;

    for(i = 0; i < nSeconds; i++) {
        eTimestamp.secondsBits[i] <== secondsBits[i];
    }

    for(i = 0; i < nNanos; i++) {
        eTimestamp.nanosBits[i] <== nanosBits[i];
    }

    component eChainID = EncodeChainID(prefixChainID, nChainID);
    for(i = 0; i < nChainID; i++) {
        eChainID.chainID[i] <== chainID[i];
    }

    for(i = 0; i < 8 + nType; i++) {
        msg[i] <== eType.out[i];
    }
    idx = 8 + nType;

    for(i = 0; i < 8 + nHeight; i++) {
        msg[i + idx] <== eHeight.out[i];
    }
    idx += 8 + nHeight;

    for(i = 0; i < 8 + nHash + nParts * (nHash + nTotal + 24); i++) {
        msg[i + idx] <== eBlockID.out[i];
    }
    idx += nHash + nParts * (nHash + nTotal + 24);

    for(i = 0; i < 32 + nSeconds + nNanos; i++) {
        msg[i + idx] <== eTimestamp.out[i];
    }
    idx += 32 + nSeconds + nNanos;

    for(i = 0; i < 16 + nChainID; i++) {
        msg[i + idx] <== eChainID.out[i];
    }
}