pragma circom 2.0.0;
include "convert.circom";
include "fieldsencode.circom";

template EncodeVersionBlock(prefix) {
    //prefix = 0x8
    var i;

    signal input block;
    
    signal output out[2];

    out[0] <== prefix;
    out[1] <== block;
}

template EncodeVersionApp(prefix) {
    //prefix = 0xa
    var i;

    signal input app;
    
    signal output out[2];

    out[0] <== prefix;
    out[1] <== app;
}

template CdcEncodeBlockTime(prefixSeconds, prefixNanos, nSeconds, nNanos) {
    signal input blockTime;
    signal output out[nSeconds + nNanos + 2];
    var seconds = blockTime / 1000000000;
    var nanos = blockTime  - seconds * 1000000000;

    component eS = EncodeTimeUnit(prefixSeconds, nSeconds);
    eS.timeUnit <== seconds;

    component eN = EncodeTimeUnit(prefixNanos, nNanos);
    eN.timeUnit <== nanos;

    for(var i = 0; i < nSeconds + 1; i++) {
        out[i] <== eS.out[i];
    }

    for(var i = 0; i < nNanos + 1; i++) {
        out[i + nSeconds + 1] <== eN.out[i];
    }
}

template CdcEncodeBlockID(prefixHash, prefixParts, prefixPartsHash, prefixPartsTotal) {
    var i;
    var j;
    var idx;

    signal input blockHash[32];
    signal input partsTotal;
    signal input partsHash[32];

    signal output out[72];

    component ps = EncodeParts(prefixParts, prefixPartsHash, prefixPartsTotal);
    ps.total <== partsTotal;
    for(i = 0; i < 32; i++) {
            ps.hash[i] <== partsHash[i];
    }
    

    out[0] <== prefixHash;
    out[1] <== 32;
    for(i = 0; i < 32; i++) {
        out[i + 2] <== blockHash[i]; 
    }

    for(i = 0; i < 38; i++) {
        out[i + 34] <== ps.out[i];
    }
}

template CdcEncodeString(prefix, n) {
    //prefix = 0xa
    signal input stringValue[n];
    signal output out[n+2];

    out[0] <== prefix;

    component sntb = SovNumToBytes(1);
    sntb.in <== n;

    out[1] <== sntb.out[0];

    for(var i = 0; i < n; i++) {
        out[i + 2] <== stringValue[i];
    }
}

template CdcEncodeInt(prefix, n) {
    //prefix = 0x8
    signal input intValue;
    signal output out[n + 1];

    out[0] <== prefix;
    
    component sntb = SovNumToBytes(n);
    sntb.in <== intValue;
    for(var i = 0; i < n; i++) {
        out[i + 1] <== sntb.out[i];
    }
}

template CdcEncodeBytes(prefix, n) {
    //prefix = 0xa
    signal input bytesValue[n];
    signal output out[n+2];

    out[0] <== prefix;

    component sntb = SovNumToBytes(1);
    sntb.in <== n;
    out[1] <== sntb.out[0];

    for(var i = 0; i < n; i++) {
        out[i + 2] <== bytesValue[i];
    }
}


