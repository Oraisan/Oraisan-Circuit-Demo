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
    var nHash = 32;
    var nParts = 1;
    var nTotal = 1;
    var len_part = 2 + nParts * (nHash + 1) + nTotal;
    var len_parts_bytes = 1;
    var len_blockID = 72;
    var len_blockID_bytes = 1;
    var blockID_bytes = 1 + len_blockID_bytes + nHash + 2 + nParts * (nHash + 2) + nTotal + 3;

    var i;
    var j;
    var idx;

    signal input blockHash[nHash];
    signal input partsTotal;
    signal input partsHash[nParts][nHash];

    signal output out[blockID_bytes];

    component sovLength = SovNumToBytes(len_blockID_bytes);
    sovLength.in <== len_blockID;

    component ps = EncodeParts(prefixParts, prefixPartsHash, prefixPartsTotal);
    ps.total <== partsTotal;
    for(i = 0; i < nParts; i++) {
        for(j = 0; j < nHash; j++) {
            ps.hash[i][j] <== partsHash[i][j];
        }
    }

    out[0] <== prefix;

    idx = 1;
    for(i = 0; i < len_blockID_bytes; i++) {
        out[i+idx] <== sovLength.out[i];
    }
    idx += len_blockID_bytes;
    out[idx] <== prefixHash;
    out[idx + 1] <== nHash;
    for(i = 0; i < nHash; i++) {
        out[i + idx + 2] <== blockHash[i]; 
    }
    idx += 2 + nHash;

    for(i = 0; i < 1 + len_parts_bytes + len_part; i++) {
        out[i + idx] <== ps.out[i];
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

