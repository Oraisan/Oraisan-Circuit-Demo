// SPDX-License-Identifier: GPL-3.0
pragma circom 2.0.0;
include "../signerinfoencode.circom";

template SignerInfosArrayEncodeVerifier(nSignerInfos, nBytesPublicKeyType, nBytesKey) {
    var nBytesSignerInfoMarshal = getLengthSignerInfoMarshal(nBytesPublicKeyType, nBytesKey);

    signal input authInfo_signerInfos_publicKey_type[nSignerInfos][nBytesPublicKeyType];
    signal input authInfo_signerInfos_publicKey_key[nSignerInfos][nBytesKey];
    signal input authInfo_signerInfos_modeInfo[nSignerInfos];
    signal input authInfo_signerInfos_sequence[nSignerInfos];

    signal input out[nSignerInfos * nBytesSignerInfoMarshal];

    var i;
    var j;
    component siae = SignerInfosArrayEncode(nSignerInfos, nBytesPublicKeyType, nBytesKey);
    for(i = 0; i < nSignerInfos; i++) {
        for(j = 0; j < nBytesPublicKeyType; j++) {
            siae.authInfo_signerInfos_publicKey_type[i][j] <== authInfo_signerInfos_publicKey_type[i][j];
        }
        for(j = 0; j < nBytesKey; j++) {
            siae.authInfo_signerInfos_publicKey_key[i][j] <== authInfo_signerInfos_publicKey_key[i][j];
        }
        siae.authInfo_signerInfos_modeInfo[i] <== authInfo_signerInfos_modeInfo[i];
        siae.authInfo_signerInfos_sequence[i] <== authInfo_signerInfos_sequence[i];
    }

    for(i = 0; i < nSignerInfos * nBytesSignerInfoMarshal; i++) {
        siae.out[i] === out[i];
        log(i, siae.out[i]);
    }
    log(siae.length);
}


component main = SignerInfosArrayEncodeVerifier(1, 31, 33);