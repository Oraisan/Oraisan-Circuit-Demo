pragma circom 2.0.0;
include "convert.circom";

template EncodeChainID(prefix, n) {
    var i;

    signal input chainID[n];
    
    signal output out[n + 2];

    out[0] <== prefix;
    out[1] <== n;
    for(var i = 0; i < n; i++) {
        out[i + 2] <== chainID[i];
    }
}

template EncodeTimeUnit(prefix, n) {
    signal input timeUnit;
    signal output out[n + 1];

    component sntb = SovNumToBytes(n);
    sntb.in <== timeUnit;
    
    out[0] <== prefix;

    for(var i = 0; i < n; i++) {
        out[i + 1] <== sntb.out[i];
    }
}

template EncodeParts(prefix, prefixPartsHash, prefixPartsTotal) {

    signal input total;
    signal input hash[32];
    signal output out[38];

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
}

