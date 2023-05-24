// SPDX-License-Identifier: GPL-3.0
pragma circom 2.0.0;
include "../sequenceencode.circom";

template SequenceEncodeVerifier() {
    var prefixSequence = 0x18;
    var nBytes = getLengthSequence();

    signal input in;
    signal input out[1 + nBytes];

    component se = SequenceEncode();
    se.in <== in;
    for(var i = 0; i < 1 + nBytes; i++) {
        se.out[i] === out[i];
    }
    log(se.length);
}

component main = SequenceEncodeVerifier();
