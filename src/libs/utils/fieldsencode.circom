pragma circom 2.0.0;
include "../../../node_modules/circomlib/circuits/bitify.circom";
include "../../../node_modules/circomlib/circuits/comparators.circom";

function Sov(x) {
    if(x % 2 == 0) {
        x++;
    }
    return ((x + 255) / 256  + 6) / 7;
}

template EncodeChainID(prefix, n) {
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

template EncodeTimeUnit(prefix, n) {
    assert(n % 8 == 0);

    signal input timeUnit;
    signal input timeUnitBits[n];
    signal output out[n + 8];

    var a = n/8;
    var t = 0;    
    component v = Bits2Num(7 * a);
    for(var i = 0; i < n; i++) {
        if(i % 8 != 7) {
            v.in[t] <== timeUnitBits[i];
            t++;
        }
    }

    component eq = IsEqual();
    eq.in[0] <== timeUnit;
    eq.in[1] <== v.out;
    eq.out === 1;

    component p = Num2Bits(8);
    p.in <== prefix;


    for(var i = 0; i < n; i++) {
        out[i + 8] <== timeUnitBits[i];
    }
}

template EncodeTimestamp(prefix, prefixSeconds, prefixNanos, nSeconds, nNanos) {

    var i;
    var idx;

    signal input seconds;
    signal input nanos;
    signal input secondsBits[nSeconds];
    signal input nanosBits[nNanos];

    signal output out[nSeconds + nNanos + 32];

    component p = Num2Bits(8);
    p.in <== prefix;
    
    component len = Num2Bits(8);
    len.in <== nSeconds + nNanos;
    
    component bs = EncodeTimeUnit(prefixSeconds, nSeconds);
    bs.timeUnit <== seconds;
    for(i = 0; i < nSeconds; i++) {
        bs.timeUnitBits[i] <== secondsBits[i];
    }

    component bn = EncodeTimeUnit(prefixNanos, nNanos);
    bn.timeUnit <== nanos;
    for(i = 0; i < nNanos; i++) {
        bn.timeUnitBits[i] <== nanosBits[i];
    }

    for(i = 0; i < 8; i++) {
        out[i] <== p.out[i];
        out[i + 8] <== len.out[i];
    }
    idx = 16;

    for(i = 0; i < 8 + nSeconds; i++) {
        out[i + idx] <== bs.out[i];
    }
    idx += 8 + nSeconds;

    for(i = 0; i < nNanos; i++) {
        out[i + idx] <== bn.out[i];
    }
}

template EncodeHash(prefix, n) {
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

template EncodeTotal(prefix, n) {
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

template EncodeParts(prefix, prefixPartsTotal, prefixPartsHash) {

    var nHash = 256;
    var nParts = 1;
    var nTotal = 8;
    var len_part = 36;
    var len_parts_bit = 8;
    var parts_bit = 304;

    var i;
    var j;
    var idx;

    signal input total[nParts];
    signal input hash[nParts][nHash];

    signal output out[parts_bit];

    component p = Num2Bits(8);
    p.in <== prefix;

    component len = Num2Bits(len_parts_bit);
    len.in <==  len_part;

    component t[nParts];
    for(i = 0; i < nParts; i++) {
        t[i] = EncodeTotal(prefixPartsTotal, nTotal);
        t[i].total <== total[i];
    }

    component h[nParts];
    for(i = 0; i < nParts; i++) {
        h[i] = EncodeHash(prefixPartsHash, nHash);
        for(j = 0; j < nHash; j++) {
            h[i].hash[j] <== hash[i][j];
        }
    } 

    for(i = 0; i < 8; i++) {
        out[i] <== p.out[i];
    }

    idx = 8;
    for(i = 0; i < 7; i++) {
        // if( i % 8 == 7) {
        //     out[i + idx] <== 1;
        //     idx++;
        // } else {
            out[i + idx] <== len.out[i];
        // }
    }

    idx = 16;
    for(i = 0; i < nParts; i++) {
        for(j = 0; j < nTotal + 8; j++) {
            out[j + idx] <== t[i].out[j];
        }
        idx += nTotal + 8;
        
        for(j = 0; j < nHash + 16; j++) {
            out[j + idx] <== h[i].out[j];
        }
        idx += nHash + 16;
    }
}

template EncodeBlockID(prefix, prefixHash, prefixParts, prefixPartsHash, prefixPartsTotal) {
    var nHash = 256;
    var nParts = 1;
    var nTotal = 8;
    var len_part = 36;
    var len_parts_bit = 8;
    var len_blockID = 72;
    var len_blockID_bit = 8 ;
    var blockID_bit = 592;

    var i;
    var j;
    var idx;

    signal input hash[nHash];
    signal input partsTotal[nParts];
    signal input partsHash[nParts][nHash];

    signal output out[blockID_bit];

    component p = Num2Bits(8);
    p.in <== prefix;

    component len = Num2Bits(len_parts_bit);
    len.in <== len_blockID;

    component h = EncodeHash(prefixHash, nHash);
    for(var i = 0; i < nHash; i ++) {
        h.hash[i] <== hash[i];
    }

    component ps = EncodeParts(prefixParts, prefixPartsHash, prefixPartsTotal);
    for(i = 0; i < nParts; i++) {
        ps.total[i] <== partsTotal[i];
        for(j = 0; j < nHash; j++) {
            ps.hash[i][j] <== partsHash[i][j];
        }
    }

    for(i = 0; i < 8; i++) {
        out[i] <== p.out[i];
    }

    idx = 8;
    for(i = 0; i < len_blockID_bit; i++) {
        if( i % 8 == 7) {
            out[i + idx] <== 1;
            idx++;
        } else {
            out[i + idx] <== len.out[i];
        }
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

template EncodeRound(prefix, n) {
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

template EncodeHeight(prefix, n) {
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

template EncodeType(prefix, n) {
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



