pragma circom 2.0.0;
include "convert.circom";
include "shiftbytes.circom";

template EncodeChainID(prefix, n) {
    var i;

    signal input chainID[n];
    signal output out[n + 2];
    signal output length;

    out[0] <== prefix;
    out[1] <== n;
    for(var i = 0; i < n; i++) {
        out[i + 2] <== chainID[i];
    }
    
    length <== n + 2;
}

template EncodeTimeUnit(prefix) {
    signal input timeUnit;
    signal output out[6];
    signal output length;

    component sntb = SovNumToBytes(5);
    sntb.in <== timeUnit;
    
    
    component tsb = TrimSovBytes(5);
    for(var i = 0; i < 5; i++) {
        tsb.in[i] <== sntb.out[i];
    }
    
    out[0] <== prefix;

    for(var i = 0; i < 5; i++) {
        out[i + 1] <== tsb.out[i];
    }
    
    length <== tsb.length + 1;
}

template EncodeParts(prefix, prefixPartsHash, prefixPartsTotal) {

    signal input total;
    signal input hash[32];
    signal output out[38];
    signal output length;

    var i;
    var j;

    component len = SovNumToBytes(1);
    len.in <==  36;

    out[0] <== prefix;
    out[1] <== len.out[0];

    out[2] <== prefixPartsTotal;
    out[3] <== total;

    out[4] <== prefixPartsHash;
    out[5] <== 32;
    
    for(i = 0; i < 32; i++) {
            out[i + 6] <== hash[i];
    }

    length <== 38;
}

