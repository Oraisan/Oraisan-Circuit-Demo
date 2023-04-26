pragma circom 2.0.0;
include "../../../node_modules/circomlib/circuits/bitify.circom";
include "../../../node_modules/circomlib/circuits/comparators.circom";
include "convert.circom";
include "fieldsencode.circom";
include "shiftbytes.circom";

template EncodeTimestamp(prefix, prefixSeconds, prefixNanos) {
    signal input seconds;
    signal input nanos;

    signal output out[14];
    signal output length;
    
    var i;
    var idx;

    component bs = EncodeTimeUnit(prefixSeconds);
    bs.timeUnit <== seconds;


    component bn = EncodeTimeUnit(prefixNanos);
    bn.timeUnit <== nanos;

    component pbot = PutBytesOnTop(6, 6);
    for(i = 0; i < 6; i++) {
        pbot.s1[i] <== bs.out[i];
    }

    pbot.idx <== bs.length;

    for(i = 0; i < 6; i++) {
        pbot.s2[i] <== bn.out[i];
    }

    out[0] <== prefix;
    out[1] <== bs.length + bn.length;
    
    for(var i = 0; i < 12; i++) {
        out[i + 2] <== pbot.out[i];
    }

    length <== bs.length + bn.length + 2;
}

template EncodeBlockID(prefix, prefixHash, prefixParts, prefixPartsHash, prefixPartsTotal) {

    signal input blockHash[32];
    signal input partsTotal;
    signal input partsHash[32];

    signal output out[74];
    signal output length;

    var i;
    var j;

    component sovLength = SovNumToBytes(1);
    sovLength.in <== 72;

    component ps = EncodeParts(prefixParts, prefixPartsHash, prefixPartsTotal);
   
    ps.total <== partsTotal;
    for(i = 0; i < 32; i++) {
        ps.hash[i] <== partsHash[i];
    }
    

    out[0] <== prefix;
    out[1] <== sovLength.out[0];
    
    out[2] <== prefixHash;
    out[3] <== 32;
    
    for(i = 0; i < 32; i++) {
        out[i + 4] <== blockHash[i]; 
    }

    for(i = 0; i < 38; i++) {
        out[i + 36] <== ps.out[i];
    }

    length <== 74;
}

template EncodeRound(prefix, n) {
    signal input round;
    signal output out[n + 1];
    signal output length;

    var i;

    //prefix = 0x11
    
    // 8 bytes store round
    component ntb = NumToBytes(n);
    ntb.in <== round;

    out[0] <== prefix;
    for(i = 0; i < n; i++) {
        out[i+1] <== ntb.out[i];
    }
    length <== n + 1;
}

template EncodeHeight(prefix, n) {
    
    signal input height;

    signal output out[n + 1];
    signal output length;

    var i;

    //prefix = 0x11
    
    // 8 bytes store height
    component ntb = NumToBytes(n);
    ntb.in <== height;

    out[0] <== prefix;
    for(i = 0; i < n; i++) {
        out[i+1] <== ntb.out[i];
    }
    length <== n + 1;
}

template EncodeType(prefix) {
    var i;

    signal input type;
    
    signal output out[2];
    signal output length;

    out[0] <== prefix;
    out[1] <== type;
    length <== 2;
}

