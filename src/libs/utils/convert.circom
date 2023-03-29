// SPDX-License-Identifier: GPL-3.0
pragma circom 2.0.0;

include "../../../node_modules/circomlib/circuits/bitify.circom";

template NumToBits(n) {
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
            bitsToBytes[i].in[7-j] <== in[i*8+j];
        }
        out[i] <== bitsToBytes[i].out;
    }
}