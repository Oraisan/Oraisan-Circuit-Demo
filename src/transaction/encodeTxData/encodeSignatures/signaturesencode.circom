// SPDX-License-Identifier: GPL-3.0
pragma circom 2.0.0;
include "../../../libs/utils/string.circom";
include "../../../libs/utils/convert.circom";
include "../../../libs/utils/shiftbytes.circom";

template SignaturesArrayEncode() {
    var nSignatures = getNSignatures();
    var nBytesSignature = getLengthSignture();
    var nBytesSignatureMarshal = getLengthSigntureMarshal();

    signal input signatures[nSignatures][nBytesSignature];
    signal output out[nSignatures * nBytesSignatureMarshal];
    signal output length;
    
    var i;
    var j;
    component se[nSignatures];
    for(i = 0; i < nSignatures; i++) {
        se[i] = SignatureEncode();
        for(j = 0; j < nBytesSignature; j++) {
            se[i].in[j] <== signatures[i][j];
        }
    }

    component pbaot = PutBytesArrayOnTop(nSignatures, nBytesSignatureMarshal);
    for(i = 0; i < nSignatures; i++) {
        for(j = 0; j < nBytesSignatureMarshal; j++) {
            pbaot.in[i][j] <== se[i].out[j];
        }
        pbaot.real_length[i] <== se[i].length;
    }

    for(i = 0; i < nSignatures * nBytesSignatureMarshal; i++) {
        out[i] <== pbaot.out[i];
    }
    length <== pbaot.length;
}

template SignatureEncode() {
    var prefixSignature = 0x1a;

    var nBytesSignature = getLengthSignture();
    var nBytesSignatureMarshal = getLengthSigntureMarshal();

    signal input in[nBytesSignature];
    signal output out[nBytesSignatureMarshal];
    signal output length;

    var i;

    component sm = StringMarshal(nBytesSignature);
    sm.prefix <== prefixSignature;
    for(i = 0; i < nBytesSignature; i++) {
        sm.in[i] <== in[i];
    }

    for(i = 0; i < nBytesSignatureMarshal; i++) {
        out[i] <== sm.out[i];
    }
    length <== sm.length;
}

function getNSignatures() {
    return 1;
}

function getLengthSignture() {
    return 64;
}

function getLengthSigntureMarshal() {
    return getLengthStringMarshal(getLengthSignture());
}

function getLengthSignturesMarshal() {
    return getNSignatures() * getLengthSigntureMarshal();
}