// SPDX-License-Identifier: GPL-3.0
pragma circom 2.0.0;
include "../../../../../lib/utils/string.circom";
include "../../../../../lib/utils/convert.circom";
include "../../../../../lib/utils/shiftbytes.circom";

template SequenceEncode() {
    var prefixSequence = 0x18;
    var nBytes = getLengthSequence();

    signal input in;
    signal output out[1 + nBytes];
    signal output length;

    var i;

    component sntb = SovNumToBytes(nBytes);
    sntb.in <== in;

    component tsb = TrimSovBytes(nBytes);
    for(i = 0; i < nBytes; i++) {
        tsb.in[i] <== sntb.out[i];
    }

    out[0] <== prefixSequence;
    for(i = 0; i < nBytes; i++) {
        out[i + 1] <== tsb.out[i];
    }
    length <== 1 + tsb.length;
}

function getLengthSequenceMarshal() {
    return 1 + getLengthSequence();
}

function getLengthSequence() {
    return 4;
}
