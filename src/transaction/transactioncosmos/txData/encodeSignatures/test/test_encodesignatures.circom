// SPDX-License-Identifier: GPL-3.0
pragma circom 2.0.0;
include "../signaturesencode.circom";

template EncodeSignaturesVeriier(nSignatures, nBytesSignature) {
     var nBytesSignatureMarshal = getLengthSigntureMarshal(nBytesSignature);
    signal input signatures[nSignatures][nBytesSignature];
    signal input signatureEncoded[nBytesSignatureMarshal * nSignatures];

    var i;
    var j;
    component sae = SignaturesArrayEncode(nSignatures, nBytesSignature);
    for(i = 0; i < nSignatures; i++) {
        for(j = 0; j < nBytesSignature; j++) {
            sae.signatures[i][j] <== signatures[i][j];
        }
    }

    for(i = 0; i < nBytesSignatureMarshal * nSignatures; i++) {
        sae.out[i] === signatureEncoded[i];
    }
    log(sae.length);
}

component main = EncodeSignaturesVeriier(1, 64);