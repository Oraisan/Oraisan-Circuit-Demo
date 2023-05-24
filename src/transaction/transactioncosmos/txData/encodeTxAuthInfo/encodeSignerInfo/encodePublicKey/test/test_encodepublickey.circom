// SPDX-License-Identifier: GPL-3.0
pragma circom 2.0.0;
include "../publickeyencode.circom";

template PublicKeyEncodeVerifier(nBytesPublicKeyType, nBytesKey) {
    var nBytesPublicKeyTypeMarshal = getLengthPublicKeyTypeMarshal(nBytesPublicKeyType);
    var nBytesPublicKeyValueMarshal = getLengthPublicKeyValueMarshal(nBytesKey);
    var nBytesPublicKey = nBytesPublicKeyTypeMarshal + nBytesPublicKeyValueMarshal;
    var nBytesPublicKeyMarshal = getLengthStringMarshal(nBytesPublicKey);

    signal input authInfo_signerInfos_publicKey_type[nBytesPublicKeyType];
    signal input authInfo_signerInfos_publicKey_key[nBytesKey];
    
    signal input out[nBytesPublicKeyMarshal];

    var i;
    var j;
    component pe = PublicKeyEncode(nBytesPublicKeyType, nBytesKey);
    for(i = 0; i < nBytesPublicKeyType; i++) {
        pe.authInfo_signerInfos_publicKey_type[i] <== authInfo_signerInfos_publicKey_type[i];
    }

    for(i = 0; i < nBytesKey; i++) {
        pe.authInfo_signerInfos_publicKey_key[i] <== authInfo_signerInfos_publicKey_key[i];
    }

    for(i = 0; i < nBytesPublicKeyMarshal; i++) {
        pe.out[i] === out[i];
    }
    log(pe.length);
}


component main = PublicKeyEncodeVerifier(31, 33);