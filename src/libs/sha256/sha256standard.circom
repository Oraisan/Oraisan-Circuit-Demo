pragma circom 2.0.0;

include "../../../node_modules/circomlib/circuits/sha256/sha256.circom";
include "../../../node_modules/circomlib/circuits/bitify.circom";

template Sha256Bytes(n) {
    signal input in[n];
    signal output out[32];

    component byteToBits[n];
    for (var i = 0; i < n; i++) {
        byteToBits[i] = Num2Bits(8);
        byteToBits[i].in <== in[i];
    }

    component sha256 = Sha256(n*8);
    for (var i = 0; i < n; i++) {
        for (var j = 0; j < 8; j++) {
            sha256.in[i*8+j] <== byteToBits[i].out[7-j];
        }
    }

    component bitsToBytes[32];
    for (var i = 0; i < 32; i++) {
        bitsToBytes[i] = Bits2Num(8);
        for (var j = 0; j < 8; j++) {
            bitsToBytes[i].in[7-j] <== sha256.out[i*8+j];
        }
        out[i] <== bitsToBytes[i].out;
    }
}
