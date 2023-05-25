// SPDX-License-Identifier: GPL-3.0
pragma circom 2.0.0;

include "../shiftbytes.circom";
include "../string.circom";

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

}

template VerifyLength(nBytes) {
    signal input in[nBytes];
    component l = Length(nBytes);
    for(var i = 0; i < nBytes; i++) {
        l.in[i] <== in[i];
    }
    log(l.out);
}

template VerifyPutBytesArrayOnTop(nArray, nBytes) {
    signal input in[nArray][nBytes];
    signal input real_length[nArray];
    signal output out[nArray * nBytes];
    component pbaot = PutBytesArrayOnTop(nArray, nBytes);
    for(var i = 0; i < nArray; i++) {
        for(var j = 0; j < nBytes; j++) {
            pbaot.in[i][j] <== in[i][j];
        }
        pbaot.real_length[i] <== real_length[i];
    }
}

template VerifyConvertAscii(nBytes) {
    signal input in[nBytes];

    var i;
    component dfib = DeleteFromInvalidBytes(nBytes);
    for(i = 0; i < nBytes; i++) {
        dfib.in[i] <== in[i];
    }

    component cabtn = ConvertAsciiBytesToNum(nBytes);
    for(i = 0; i < nBytes; i++) {
        cabtn.in[i] <== dfib.out[i];
    }
    cabtn.length <== dfib.length;

    log(cabtn.out);
}
component main = VerifyConvertAscii(77);