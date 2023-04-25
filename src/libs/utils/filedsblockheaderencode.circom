pragma circom 2.0.0;
include "convert.circom";
include "fieldsencode.circom";
include "shiftbytes.circom";

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

template CdcEncodeBlockTime(prefixSeconds, prefixNanos) {
    signal input blockTime;
    signal output out[12];
    signal output length;

    var i;
    var seconds = blockTime / 1000000000;
    var nanos = blockTime  - seconds * 1000000000;

    component eS = EncodeTimeUnit(prefixSeconds);
    eS.timeUnit <== seconds;

    component eN = EncodeTimeUnit(prefixNanos);
    eN.timeUnit <== nanos;

    component pbot = PutBytesOnTop(6, 6);
    for(i = 0; i < 6; i++) {
        pbot.s1[i] <== eS.out[i];
    }

    pbot.idx <== eS.length;

    for(i = 0; i < 6; i++) {
        pbot.s2[i] <== eN.out[i];
    }

    for(i = 0; i < 12; i++) {
        out[i] <== pbot.out[i];
    }

    length <== eS.length + eN.length;
}

template CdcEncodeBlockID(prefixHash, prefixParts, prefixPartsHash, prefixPartsTotal) {
    signal input blockHash[32];
    signal input partsTotal;
    signal input partsHash[32];

    signal output out[72];
    signal output length;

    var i;
    var j;
    var idx;

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

    length <== 72;
}

template CdcEncodeString(prefix, n) {
    //prefix = 0xa
    signal input stringValue[n];
    signal output out[n+2];
    signal output length;

    out[0] <== prefix;

    component sntb = SovNumToBytes(1);
    sntb.in <== n;

    out[1] <== sntb.out[0];

    for(var i = 0; i < n; i++) {
        out[i + 2] <== stringValue[i];
    }

    length <== n + 2;
}

template CdcEncodeInt(prefix, n) {
    //prefix = 0x8
    signal input intValue;
    signal output out[n + 1];
    signal output length;

    
    component sntb = SovNumToBytes(n);
    sntb.in <== intValue;

    component tsb = TrimSovBytes(n);
    for(var i = 0; i < n; i++) {
        tsb.in[i] <== sntb.out[i];
    }

    out[0] <== prefix;
    
    for(var i = 0; i < n; i++) {
        out[i + 1] <== tsb.out[i];
    }

    length <== tsb.length + 1;
}

template CdcEncodeBytes(prefix, n) {
    //prefix = 0xa
    signal input bytesValue[n];
    signal output out[n+2];
    signal output length;

    out[0] <== prefix;

    component sntb = SovNumToBytes(1);
    sntb.in <== n;
    out[1] <== sntb.out[0];

    for(var i = 0; i < n; i++) {
        out[i + 2] <== bytesValue[i];
    }
    
    length <== n + 2;
}


