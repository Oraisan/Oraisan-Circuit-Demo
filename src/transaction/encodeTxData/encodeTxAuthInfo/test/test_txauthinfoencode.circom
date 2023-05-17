// SPDX-License-Identifier: GPL-3.0
pragma circom 2.0.0;
include "../txauthinfoencode.circom";

template AuthInfoEncodeVerifier(nSignerInfos, nBytesPublicKeyType, nBytesKey, nAmount) {
    var nBytesFeeDenom = getLengthFeeDenom();
    var nBytesFeeAmount = getLengthFeeAmount();

    var nBytesSignerInfoMarshal = getLengthSignerInfoMarshal(nBytesPublicKeyType, nBytesKey);
    var nBytesFeeMarshal = getLengthFeeMarshal(nAmount);
    var nBytesAuthInfo = nBytesSignerInfoMarshal + nBytesFeeMarshal;
    var nBytesAuthInfoMarshal = getLengthStringMarshal(nBytesAuthInfo);

    signal input authInfo_signerInfos_publicKey_type[nSignerInfos][nBytesPublicKeyType];
    signal input authInfo_signerInfos_publicKey_key[nSignerInfos][nBytesKey];
    signal input authInfo_signerInfos_modeInfo[nSignerInfos];
    signal input authInfo_signerInfos_sequence[nSignerInfos];
    signal input authInfo_fee_amount_denom[nAmount][nBytesFeeDenom];
    signal input authInfo_fee_amount_amount[nAmount][nBytesFeeAmount];
    signal input authInfo_fee_gasLimit;

    signal input out[nBytesAuthInfoMarshal];

    var i;
    var j;
    component aie = AuthInfoEncode(nSignerInfos, nBytesPublicKeyType, nBytesKey, nAmount);
    for(i = 0; i < nSignerInfos; i++) {
        for(j = 0; j < nBytesPublicKeyType; j++) {
            aie.authInfo_signerInfos_publicKey_type[i][j] <== authInfo_signerInfos_publicKey_type[i][j];
        }
        for(j = 0; j < nBytesKey; j++) {
            aie.authInfo_signerInfos_publicKey_key[i][j] <== authInfo_signerInfos_publicKey_key[i][j];
        }
        aie.authInfo_signerInfos_modeInfo[i] <== authInfo_signerInfos_modeInfo[i];
        aie.authInfo_signerInfos_sequence[i] <== authInfo_signerInfos_sequence[i];
    }

    for(i = 0; i < nAmount; i++) {
        for(j = 0; j < nBytesFeeDenom; j++) {
            aie.authInfo_fee_amount_denom[i][j] <== authInfo_fee_amount_denom[i][j];
        }

        for(j = 0; j < nBytesFeeAmount; j++) {
            aie.authInfo_fee_amount_amount[i][j] <== authInfo_fee_amount_amount[i][j];
        }
    }
    aie.authInfo_fee_gasLimit <== authInfo_fee_gasLimit;

    for(i = 0; i < nSignerInfos * nBytesSignerInfoMarshal; i++) {
        aie.out[i] === out[i];
        log(i, aie.out[i]);
    }
    log(aie.length);
}


component main = AuthInfoEncodeVerifier(1, 31, 33, 1);