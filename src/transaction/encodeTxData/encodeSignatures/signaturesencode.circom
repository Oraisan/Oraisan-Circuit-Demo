// SPDX-License-Identifier: GPL-3.0
pragma circom 2.0.0;
include "../../../lib/utils/string.circom";
include "../../../lib/utils/convert.circom";
include "../../../lib/utils/shiftbytes.circom";

template SignaturesArrayEncode(nSignatures, nBytesSignature) {
    var nBytesSignatureMarshal = getLengthSigntureMarshal(nBytesSignature);

    signal input signatures[nSignatures][nBytesSignature];
    signal output out[nSignatures * nBytesSignatureMarshal];
    signal output length;
    
    var i;
    var j;
    component se[nSignatures];
    for(i = 0; i < nSignatures; i++) {
        se[i] = SignatureEncode(nBytesSignature);
        for(j = 0; j < nBytesSignature; j++) {
            se[i].in[j] <== signatures[i][j];
        }
    }

    component pbaot = PutBytesArrayOnTop(nSignatures, nBytesSequenceMarshal);
    for(i = 0; i < nSignatures; i++) {
        for(j = 0; j < nBytesSignatureMarshal; j++) {
            pbaot.in[i][j] <== se[i].out[j];
        }
        pbaot.length[i] <== se.length;
    }

    for(i = 0; i < nSignatures * nBytesSignatureMarshal; i++) {
        out[i] <== pbaot.out[i];
    }
    length <== pbaot.length;
}

template SignatureEncode(nBytesSignature) {
    var prefixSignature = 0x1a;
    var nBytesSignatureMarshal = getLengthSigntureMarshal(nBytesSignature);

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

function getLengthSigntureMarshal(nBytesSignature) {
    return getLengthStringMarshal(nBytesSignature);
}