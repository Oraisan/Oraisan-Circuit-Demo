// SPDX-License-Identifier: GPL-3.0
pragma circom 2.0.0;

include "../shiftbytes.circom";

template VerifyShift(nBytesFirst, nBytesLast) {
    signal input s1[nBytesFirst];
    signal input s2[nBytesLast];
    signal input out[nBytesFirst + nBytesLast];

    component r = PutBytesOnTop(nBytesFirst, nBytesLast);
    for(var i = 0; i < nBytesFirst; i++) {
        r.s1[i] <== s1[i];
    }

    for(var i = 0; i < nBytesLast; i++) {
        r.s2[i] <== s2[i];
    }

    r.idx <== 3;

    for(var i = 0; i < nBytesFirst + nBytesLast; i++) {
        out[i] === r.out[i];
    }
}

template VerifySovByte(nBytes) {
    signal input in;
    signal input out[nBytes];

    component sntb = SovNumToBytes(nBytes);
    sntb.in <== in;

    component tsb = TrimSovBytes(nBytes);
    for(var i = 0; i < nBytes; i++) {
        tsb.in[i] <== sntb.out[i];
    }

    for(var i = 0; i < nBytes; i++) {
        out[i] === tsb.out[i];
    }

    log(tsb.length);
}
component main = VerifySovByte(5);