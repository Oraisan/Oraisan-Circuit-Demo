pragma circom 2.0.0;
include "../../../node_modules/circomlib/circuits/bitify.circom";

template encodeHash(prefix, n) {
    assert(n % 8 == 0);

    signal input hash[n];
    // 8 bit prefix + 8 bit len(hash) + hash
    signal output out[n+16];

    component p = Num2Bits(8);
    p.in <== prefix;

    component len = Num2Bits(8);
    len.in <== n;

    for(i = 0; i < 8; i++) {
        out[i] <== p.out[i];
        out[i+8] <== len.out[i];
    }

    for(i = 0; i < n; i++) {
        out[i+16] <== hash[i];
    }
}

template encodeBlockID(prefix, n) {
    signal input hash[n];
    signal input partsTotal;
    signal input partsHash;
}

template encodeRound(prefix, n) {
    assert(n % 8 == 0)
    
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

template encodeHeight(prefix, n) {
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

template encodeType(prefix, n) {
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



