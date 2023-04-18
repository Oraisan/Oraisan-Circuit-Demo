// SPDX-License-Identifier: GPL-3.0
pragma circom 2.0.0;

include "../../../node_modules/circomlib/circuits/bitify.circom";

template BytesToBits(n) {
    signal input in;
    signal output out[n];

    component byteToBits = Num2Bits(n);
    byteToBits.in <== in;

    for(var i = 0; i < n; i++) {
        out[i] <== byteToBits.out[i];
    }

}

template BitsToBytes(nBytes) {
    signal input in[8*nBytes];
    signal output out[nBytes];

    component bitsToBytes[nBytes];
    for (var i = 0; i < nBytes; i++) {
        bitsToBytes[i] = Bits2Num(8);
        for (var j = 0; j < 8; j++) {
            bitsToBytes[i].in[j] <== in[i*8+j];
        }
        out[i] <== bitsToBytes[i].out;
    }
}

template NumToBytes(nBytes) {
    signal input in;
    signal output out[nBytes];

    component ntb = Num2Bits(8 * nBytes);
    ntb.in <== in;

    component btb = BitsToBytes(nBytes);
    for(var i = 0; i < 8 * nBytes; i++) {
        btb.in[i] <== ntb.out[i];
    }

    for(var i = 0; i < nBytes; i++) {
        out[i] <== btb.out[i];
    }
}

template SovNumToBytes(nBytes) {
    signal input in;
    signal output out[nBytes];

    var i;
    component sntb = SovNumToBits(8 * nBytes);
    sntb.in <== in;

    component bitsToBytes = BitsToBytes(nBytes);
    for(i = 0; i < 8 * nBytes; i++) {
        bitsToBytes.in[i] <== sntb.out[i];
    }

    for(i = 0; i < nBytes; i++) {
        out[i] <== bitsToBytes.out[i];
    }
}

template SovNumToBits(nBits) {
    assert(nBits % 8 == 0);

    signal input in;
    signal output out[nBits];

    component numToBits = Num2Bits(7 * nBits / 8);
    numToBits.in <== in;

    var i;
    var cnt = 0;
    for(i = 0; i < nBits - 1; i++) {
        if( i % 8 == 7) {
            out[i] <== 1;
            cnt++;
        } else {
            out[i] <== numToBits.out[i - cnt];
        }
    }
    out[nBits - 1] <== 0;
}

template SwitchSovByte() {
    signal input xor;
    signal input in;
    signal output out;

    component numToBits = Num2Bits(8);
    numToBits.in <== in;

    component bitsToBytes = BitsToBytes(1);
    for(var i = 0; i < 7; i++) {
        bitsToBytes.in[i] <== numToBits.out[i];
    }

    bitsToBytes.in[7] <== xor;

    out <== bitsToBytes.out[0];
}
