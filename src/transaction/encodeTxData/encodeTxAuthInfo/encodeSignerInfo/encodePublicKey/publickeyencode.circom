// SPDX-License-Identifier: GPL-3.0
pragma circom 2.0.0;
include "../../../../../libs/utils/string.circom";
include "../../../../../libs/utils/convert.circom";
include "../../../../../libs/utils/shiftbytes.circom";

template PublicKeyEncode(nBytesPublicKeyType, nBytesPublicKey) {
    var prefixPublicKey = 0xa;

    var nBytesPublicKeyTypeMarshal = getLengthPublicKeyTypeMarshal(nBytes);
    var nBytesPublicKeyValueMarshal = getLengthPublicKeyValueMarshal(nBytes);
    var nBytesPublicKey = nBytesPublicKeyTypeMarshal + nBytesPublicKeyValueMarshal;
    var nBytesPublicKeyMarshal = getLengthStringMarshal(nBytesPublicKey);

    signal input authInfo_signerInfos_publicKey_type[nBytesPublicKeyType];
    signal input authInfo_signerInfos_publicKey_key[nBytesPublicKey];
    
    signal output out[nBytesPublicKeyMarshal];
    signal output length;

    var i;

    component pktue = PublicKeyTypeUrlEncode(nBytesPublicKeyType);
    for(i = 0; i < nBytesPublicKeyType; i++) {
        pktue.in[i] <== authInfo_signerInfos_publicKey_type[i];
    }

    component pkve = PublicKeyValueEncode(nBytesPublicKey);
    for(i = 0; i < nBytesPublicKey; i++) {
        pkve.in[i] <== authInfo_signerInfos_publicKey_key[i];
    }

    component pbot = PutBytesOnTop(nBytesPublicKeyTypeMarshal, nBytesPublicKeyValueMarshal);
    for(i = 0; i < nBytesPublicKeyTypeMarshal; i++) {
        pbot.s1[i] <== pktue.out[i];
    }
    pbot.idx <== pktue.length;

    for(i = 0; i < nBytesPublicKeyValueMarshal; i++) {
        pbot.s2[i] <== pkve.out[i];
    }

    component sm = StringMarshal(nBytesPublicKey);
    sm.prefix <== prefixPublicKey;
    for(i = 0; i < nBytesPublicKey; i++) {
        sm.in[i] <== pbot.out[i];
    }

    for(i = 0; i < nBytesPublicKeyMarshal; i++) {
        out[i] <== sm.out[i];
    }
    length <== sm.length;
}

template PublicKeyValueEncode(nBytes) {
    var prefixKey = 0xa;
    var prefixValue = 0x12;

    var nBytesPublicKeyMarshal = getLengthPublicKeyMarshal(nBytes);
    var nBytesPublicKeyValueMarshal = getLengthPublicKeyValueMarshal(nBytes);

    signal input in[nBytes];
    
    signal output out[nBytesPublicKeyValueMarshal];
    signal output length;

    var i;

    component smKey = StringMarshal(nBytes);
    smKey.prefix <== prefixKey;
    for(i = 0; i < nBytes; i++) {
        smKey.in[i] <== in[i];
    }

    component smValue = StringMarshal(nBytesPublicKeyMarshal);
    smValue.prefix <== prefixValue;
    for(i = 0; i < nBytesPublicKeyMarshal; i++) {
        smValue.in[i] <== smKey.out[i];
    }

    for(i = 0; i < nBytesPublicKeyValueMarshal; i++) {
        out[i] <== smValue.out[i];
    }
    length <== smValue.length;
}

template PublicKeyTypeUrlEncode(nBytes) {
    var prefixType = 0xa;

    var nBytesPublicKeyTypeMarshal = getLengthPublicKeyTypeMarshal(nBytes);

    signal input in[nBytes];

    signal output out[nBytesPublicKeyTypeMarshal];
    signal output length;

    var i;
    
    component sm = StringMarshal(nBytes);
    sm.prefix <== prefixType;
    for(i = 0; i < nBytes; i++) {
        sm.in[i] <== in[i];
    }

    for(i = 0; i < nBytesPublicKeyTypeMarshal; i++) {
        out[i] <== sm.out[i];
    }
    
    length <== sm.length;
}

function getLengthPublicKeyTypeMarshal(nBytesPublicKeyType) {
    return getLengthStringMarshal(nBytesPublicKeyType);
}

function getLengthPublicKeyMarshal(nBytesPublicKey) {
    return getLengthStringMarshal(nBytesPublicKey);
}

function getLengthPublicKeyValueMarshal(nBytesPublicKey) {
    return getLengthStringMarshal(getLengthStringMarshal(nBytesPublicKey));
}

function getLengthPublicKey(nBytesPublicKeyType, nBytesPublicKey) {
    return getLengthPublicKeyTypeMarshal(nBytesPublicKeyType) + getLengthPublicKeyValueMarshal(nBytesPublicKey);
}

function getLengthPublicKeyMarshal(nBytesPublicKeyType, nBytesPublicKey) {
    return getLengthStringMarshal(getLengthPublicKey(nBytesPublicKeyType, nBytesPublicKey));
}