pragma circom 2.0.0;
include "../../../node_modules/circomlib/circuits/bitify.circom";
include "../../../node_modules/circomlib/circuits/comparators.circom";
include "convert.circom";
include "fieldsencode.circom";

template EncodeTimestamp(prefix, prefixSeconds, prefixNanos, nSeconds, nNanos) {
    
    // var nSeconds = 5;
    // var nNanos = 5;
    
    var i;
    var idx;

    signal input seconds;
    signal input nanos;

    signal output out[nSeconds + nNanos + 4];
    
    component bs = EncodeTimeUnit(prefixSeconds, nSeconds);
    bs.timeUnit <== seconds;


    component bn = EncodeTimeUnit(prefixNanos, nNanos);
    bn.timeUnit <== nanos;

    out[0] <== prefix;
    out[1] <== nSeconds + nNanos + 2;
    idx = 2;

    for(i = 0; i < 1 + nSeconds; i++) {
        out[i + idx] <== bs.out[i];
    }
    idx += 1 + nSeconds;

    for(i = 0; i < 1 + nNanos; i++) {
        out[i + idx] <== bn.out[i];
    }
}

template EncodeBlockID(prefix, prefixHash, prefixParts, prefixPartsHash, prefixPartsTotal) {

    signal input blockHash[32];
    signal input partsTotal;
    signal input partsHash[32];

    signal output out[74];
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
}

template EncodeRound(prefix, n) {
    signal input round;
    signal output out[n + 1];
    
    var i;

    //prefix = 0x11
    
    // 8 bytes store round
    component ntb = NumToBytes(n);
    ntb.in <== round;

    out[0] <== prefix;
    for(i = 0; i < n; i++) {
        out[i+1] <== ntb.out[i];
    }
}

template EncodeHeight(prefix, n) {
    
    signal input height;
    signal output out[n + 1];
    
    var i;

    //prefix = 0x11
    
    // 8 bytes store height
    component ntb = NumToBytes(n);
    ntb.in <== height;

    out[0] <== prefix;
    for(i = 0; i < n; i++) {
        out[i+1] <== ntb.out[i];
    }
}

template EncodeType(prefix) {
    var i;

    signal input type;
    
    signal output out[2];

    out[0] <== prefix;
    out[1] <== type;
}

