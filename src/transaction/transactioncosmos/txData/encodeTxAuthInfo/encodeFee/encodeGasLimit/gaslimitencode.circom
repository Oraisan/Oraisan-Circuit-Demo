// SPDX-License-Identifier: GPL-3.0
pragma circom 2.0.0;
include "../../../../../libs/utils/string.circom";
include "../../../../../libs/utils/convert.circom";
include "../../../../../libs/utils/shiftbytes.circom";

template GasLimitEncode() {
    var prefixGasLimit = 0x10;
    var nBytes = getLengthGasLimit();

    signal input authInfo_fee_gasLimit;

    signal output out[1 + nBytes];
    signal output length;

    var i;

    component sntb = SovNumToBytes(nBytes);
    sntb.in <== authInfo_fee_gasLimit;

    component tsb = TrimSovBytes(nBytes);
    for(i = 0; i < nBytes; i++) {
        tsb.in[i] <== sntb.out[i];
    }

    out[0] <== prefixGasLimit;

    for(i = 0; i < nBytes; i++) {
        out[i + 1] <== tsb.out[i];
    }
    length <== tsb.length + 1;
}

function getLengthGasLimitMarshal() {
    return 1 + getLengthGasLimit();
}

function getLengthGasLimit() {
    return 4;
}