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

    var nHash = 32;
    var nParts = 1;
    var nTotal = 1;
    var len_part = 2 + nParts * (nHash + 1) + nTotal;
    var len_parts_bytes = 1;
    var parts_bytes = 1 + len_parts_bytes + nParts * (nHash + 2) + nTotal + 3;

    var i;
    var j;
    var idx;

    signal input total;
    signal input hash[nParts][nHash];

    signal output out[parts_bytes];

    component len = SovNumToBytes(len_parts_bytes);
    len.in <==  len_part;

    out[0] <== prefix;
    idx = 1;

    for(i = 0; i < len_parts_bytes; i++) {
        out[i + idx] <== len.out[i];
    }
    idx += len_parts_bytes;

    out[idx] <== prefixPartsTotal;
    out[idx + 1] <== total;

    idx += 2;
    for(i = 0; i < nParts; i++) {
        out[idx] <== prefixPartsHash;
        out[idx + 1] <== nHash;
        for(j = 0; j < nHash; j++) {
            out[j + idx + 2] <== hash[i][j];
        }

        idx += nHash + 3;
    }
}

