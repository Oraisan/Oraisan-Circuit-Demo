pragma circom 2.0.0;
include "../../../node_modules/circomlib/circuits/bitify.circom";
include "../../../node_modules/circomlib/circuits/comparators.circom";
include "convert.circom";

template EncodeChainIDToBytes(prefix, n) {
    var i;

    signal input chainID[n];
    
    signal output out[n + 2];

    out[0] <== prefix;
    out[1] <== n;

    for(i = 0; i < n; i++) {
        out[i + 2] <== chainID[i];
    }
}


template EncodeChainIDToBits(prefix, n) {
    assert(n % 8 == 0);

    var a = n/8;
    var i;

    signal input chainID[n];
    
    signal output out[n + 16];


    component p = Num2Bits(8);
    p.in <== prefix;

    component len = Num2Bits(8);
    len.in <== a;    

    for(i = 0; i < 8; i++) {
        out[i] <== p.out[i];
        out[i + 8] <== len.out[i];
    }

    for(i = 0; i < n; i++) {
        out[i + 16] <== chainID[i];
    }
}

template EncodeTimeUnitToBytes(prefix, n) {
    signal input timeUnit;
    signal output out[n + 1];

    component sntb = SovNumToBytes(n);
    sntb.in <== timeUnit;
    
    out[0] <== prefix;

    for(var i = 0; i < n; i++) {
        out[i + 1] <== sntb.out[i];
    }
}

template EncodeTimeUnitToBits(prefix, n) {
    assert(n % 8 == 0);

    signal input timeUnit;
    signal output out[n + 8];

    component v = SovNumToBits(n);
    v.in <== timeUnit;

    var cnt = 0;

    component p = Num2Bits(8);
    p.in <== prefix;

    for(var i = 0; i < 8; i++) {
        out[i] <== p.out[i];
    }

    for(var i = 0; i < n - 1; i++) {
        out[i + 8] <== v.out[i];
    }
}

template EncodeTimestampToBytes(prefix, prefixSeconds, prefixNanos) {
    
    var nSeconds = 5;
    var nNanos = 5;
    
    var i;
    var idx;

    signal input seconds;
    signal input nanos;

    signal output out[nSeconds + nNanos + 4];
    
    component bs = EncodeTimeUnitToBytes(prefixSeconds, nSeconds);
    bs.timeUnit <== seconds;


    component bn = EncodeTimeUnitToBytes(prefixNanos, nNanos);
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

template EncodeTimestampToBits(prefix, prefixSeconds, prefixNanos) {
    
    var nSeconds = 40;
    var nNanos = 40;
    
    var i;
    var idx;

    signal input seconds;
    signal input nanos;

    signal output out[nSeconds + nNanos + 32];

    component p = Num2Bits(8);
    p.in <== prefix;
    
    component len = Num2Bits(8);
    len.in <== nSeconds/8 + nNanos/8 + 2;
    
    component bs = EncodeTimeUnitToBits(prefixSeconds, nSeconds);
    bs.timeUnit <== seconds;


    component bn = EncodeTimeUnitToBits(prefixNanos, nNanos);
    bn.timeUnit <== nanos;

    for(i = 0; i < 8; i++) {
        out[i] <== p.out[i];
        out[i + 8] <== len.out[i];
    }
    idx = 16;

    for(i = 0; i < 8 + nSeconds; i++) {
        out[i + idx] <== bs.out[i];
    }
    idx += 8 + nSeconds;

    for(i = 0; i < 8 + nNanos; i++) {
        out[i + idx] <== bn.out[i];
    }
}

template EncodeHashToBits(prefix, n) {
    assert(n % 8 == 0);

    signal input hash[n];
    // 8 bit prefix + 8 bit len(hash) + hash
    signal output out[n+16];

    var i;

    component p = Num2Bits(8);
    p.in <== prefix;

    component len = Num2Bits(8);
    len.in <-- n/8;

    for(i = 0; i < 8; i++) {
        out[i] <== p.out[i];
        out[i+8] <== len.out[i];
    }

    for(i = 0; i < n; i++) {
        out[i+16] <== hash[i];
    }
}


template EncodeTotalToBits(prefix, n) {
    assert(n % 8 == 0);

    signal input total;
    signal output out[n+8];

    var i;

    component p = Num2Bits(8);
    p.in <== prefix;

    component t = Num2Bits(n);
    t.in <== total;

    for(i = 0; i < 8; i++) {
        out[i] <== p.out[i];
    }

    for(i = 0; i < n; i++) {
        out[i+8] <== t.out[i];
    }
}

template EncodePartsToBytes(prefix, prefixPartsHash, prefixPartsTotal) {

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

template EncodePartsToBits(prefix, prefixPartsHash, prefixPartsTotal) {

    var nHash = 256;
    var nParts = 1;
    var nTotal = 8;
    var len_part = 2 + nParts * (nHash / 8 + 1) + nTotal/8;
    var len_parts_bit = 8;
    var parts_bit = 8 + len_parts_bit + nParts * (nHash + nTotal + 40);

    var i;
    var j;
    var idx;

    signal input total;
    signal input hash[nParts][nHash];

    signal output out[parts_bit];

    component p = Num2Bits(8);
    p.in <== prefix;

    component len = SovNumToBits(len_parts_bit);
    len.in <==  len_part;

    component t = EncodeTotalToBits(prefixPartsTotal, nTotal);
        t.total <== total;

    component h[nParts];
    for(i = 0; i < nParts; i++) {
        h[i] = EncodeHashToBits(prefixPartsHash, nHash);
        for(j = 0; j < nHash; j++) {
            h[i].hash[j] <== hash[i][j];
        }
    } 

    for(i = 0; i < 8; i++) {
        out[i] <== p.out[i];
    }

    idx = 8;
    for(i = 0; i < len_parts_bit - 1; i++) {
        out[i + idx] <== len.out[i];
    }

    idx += len_parts_bit;
    for(j = 0; j < nTotal + 8; j++) {
            out[j + idx] <== t.out[j];
    }
    idx += nTotal + 8;
    
    for(i = 0; i < nParts; i++) {
        for(j = 0; j < nHash + 16; j++) {
            out[j + idx] <== h[i].out[j];
        }
        idx += nHash + 16;
    }
}

template EncodeBlockIDToBytes(prefix, prefixHash, prefixParts, prefixPartsHash, prefixPartsTotal) {
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

    component ps = EncodePartsToBytes(prefixParts, prefixPartsHash, prefixPartsTotal);
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

template EncodeBlockIDToBits(prefix, prefixHash, prefixParts, prefixPartsHash, prefixPartsTotal) {
    var nHash = 256;
    var nParts = 1;
    var nTotal = 8;
    var len_part = 2 + nParts * (nHash / 8 + 1) + nTotal/8;
    var len_parts_bit = 8;
    var len_blockID = 72;
    var len_blockID_bit = 8 ;
    var blockID_bit = 8 + len_blockID_bit + nHash + 16 + nParts * (nHash + 16) + nTotal + 24;

    var i;
    var j;
    var idx;

    signal input blockHash[nHash];
    signal input partsTotal;
    signal input partsHash[nParts][nHash];

    signal output out[blockID_bit];

    component p = Num2Bits(8);
    p.in <== prefix;

    component len = SovNumToBits(len_blockID_bit);
    len.in <== len_blockID;

    component h = EncodeHashToBits(prefixHash, nHash);
    for(var i = 0; i < nHash; i ++) {
        h.hash[i] <== blockHash[i];
    }

    component ps = EncodePartsToBits(prefixParts, prefixPartsHash, prefixPartsTotal);
    ps.total <== partsTotal;

    for(i = 0; i < nParts; i++) {
        for(j = 0; j < nHash; j++) {
            ps.hash[i][j] <== partsHash[i][j];
        }
    }

    for(i = 0; i < 8; i++) {
        out[i] <== p.out[i];
    }

    idx = 8;
    for(i = 0; i < len_blockID_bit - 1; i++) {
        out[i + idx] <== len.out[i];
    }

    idx += len_blockID_bit;
    for(i = 0; i < 16 + nHash; i++) {
        out[i + idx] <== h.out[i]; 
        
    }

    idx += 16 + nHash;

    for(i = 0; i < 8 + len_parts_bit + len_part * 8; i++) {
        out[i + idx] <== ps.out[i];
    }
}

template EncodeRoundToBytes(prefix, n) {
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

template EncodeRoundToBits(prefix, n) {
    assert(n % 8 == 0);
    
    // default round = 0
    signal input round;
    signal output out[n + 8];
    
    var i;

    //prefix = 0x19
    component p = Num2Bits(8);
    p.in <== prefix;
    
    // 8 bytes store round
    component ntb = Num2Bits(n);
    ntb.in <== round;

    for(i = 0; i < 8; i++) {
        out[i] <== p.out[i];
    }
    for(i = 0; i < n; i++) {
        out[i+8] <== ntb.out[i];
    }
}

template EncodeHeightToBytes(prefix, n) {
    
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


template EncodeHeightToBits(prefix, n) {
    assert(n % 8 == 0);
    
    signal input height;
    signal output out[n + 8];
    
    var i;

    //prefix = 0x11
    component p = Num2Bits(8);
    p.in <== prefix;
    
    // 8 bytes store height
    component ntb = Num2Bits(n);
    ntb.in <== height;

    for(i = 0; i < 8; i++) {
        out[i] <== p.out[i];
    }
    for(i = 0; i < n; i++) {
        out[i+8] <== ntb.out[i];
    }
}

template EncodeTypeToBits(prefix, n) {
    assert(n % 8 == 0);
    
    // default type = 2
    signal input type;
    signal output out[n + 8];
    
    var i;

    //prefix = 0x08
    component p = Num2Bits(8);
    p.in <== prefix;
    
    // 1 byte store type
    component ntb = Num2Bits(n);
    ntb.in <== type;

    for(i = 0; i < 8; i++) {
        out[i] <== p.out[i];
    }
    for(i = 0; i < n; i++) {
        out[i+8] <== ntb.out[i];
    }
}

template EncodeLengthMsgToBits(n) {
    signal input len;
    signal output out[n];

    // 1 byte store type
    component ntb = Num2Bits(n);
    ntb.in <== len;

    for(var i = 0; i < n; i++) {
        out[i] <== ntb.out[i];
    }
}