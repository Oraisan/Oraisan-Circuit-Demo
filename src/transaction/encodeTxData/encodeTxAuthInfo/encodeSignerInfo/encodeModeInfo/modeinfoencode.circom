// SPDX-License-Identifier: GPL-3.0
pragma circom 2.0.0;
include "../../../../../libs/utils/string.circom";
include "../../../../../libs/utils/convert.circom";
include "../../../../../libs/utils/shiftbytes.circom";

template ModeInfoEncode() {
    var prefixModeInfo = 0x12;
    var nBytesSingleMarshal  = getLengthSingleMarshal();
    var nBytesModeInfoMarshal = getLengthStringMarshal(nBytesSingleMarshal);

    signal input in;
    signal output out[nBytesModeInfoMarshal];
    signal output length;

    var i;

    component se = SingleEncode();
    se.in <== in;

    component sm = StringMarshal(nBytesSingleMarshal);
    sm.prefix <== prefixModeInfo;
    for(i = 0; i < nBytesSingleMarshal; i++) {
        sm.in[i] <== se.out[i];
    }

    for(i = 0; i < nBytesModeInfoMarshal; i++) {
        out[i] <== sm.out[i];
    }
    length <== sm.length;
}

template SingleEncode() {
    var prefixSingle = 0xa;

    var nBytes = getLengthMode();
    var nBytesSingleMarshal  = getLengthSingleMarshal();

    signal input in;

    signal output out[nBytesSingleMarshal];
    signal output length;

    var i;
    component me = ModeEncode();
    me.in <== in;

    component sm = StringMarshal(1 + nBytes);
    sm.prefix <== prefixSingle;
    for(i = 0; i < 1 + nBytes; i++) {
        sm.in[i] <== me.out[i];
    }

    for(i = 0; i < nBytesSingleMarshal; i++) {
        out[i] <== sm.out[i];
    }
    length <== sm.length;
}

template ModeEncode() {
    var prefixMode = 0x8;
    var nBytes = getLengthMode();

    signal input in;
    signal output out[nBytes + 1];
    signal output length;

    var i;

    component sntb = SovNumToBytes(nBytes);
    sntb.in <== in;

    component tsb = TrimSovBytes(nBytes);
    for(i = 0; i < nBytes; i++) {
        tsb.in[i] <== sntb.out[i];
    }

    out[0] <== prefixMode;
    
    for(i = 0; i < nBytes; i++) {
        out[i + 1] <== tsb.out[i];
    }
    length <== tsb.length;
}

function getLengthModeInfoMarshal() {
    return getLengthStringMarshal(getLengthSingleMarshal());
}

function getLengthSingleMarshal() {
    return getLengthStringMarshal(getLengthModeMarshal());
}

function getLengthModeMarshal() {
    return 1 + getLengthMode();
}

function getLengthMode() {
    return 2;
}
