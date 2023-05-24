// SPDX-License-Identifier: GPL-3.0
pragma circom 2.0.0;
include "../../../../../libs/utils/string.circom";
include "../../../../../libs/utils/convert.circom";
include "../../../../../libs/utils/shiftbytes.circom";

template PublicKeyEncodeDefault() {

    // var nBytesPublicKeyType = getLengthPublicKeyType();
    var nBytesKey = getLengthKey();

    signal input authInfo_signerInfos_publicKey_key[nBytesKey];
    signal output out[nBytesKey + 39];
    signal output length;

    var left_part = [10, 70, 10, 31, 47, 99, 111, 115, 109, 111, 115, 46, 99, 114, 121, 112, 116, 111, 46, 115, 101, 99, 112, 50, 53, 54, 107, 49, 46, 80, 117, 98, 75, 101, 121, 18, 35, 10, 33];
    for(var i = 0; i < 39; i++){
        out[i] <== left_part[i];
    }
    for(var i = 0; i < nBytesKey; i++) {
        out[i + 39] <== authInfo_signerInfos_publicKey_key[i];
    }
    length <== nBytesKey + 39;
}   
template PublicKeyEncode() {
    var prefixPublicKey = getPrefixPublicKey();

    var nBytesPublicKeyType = getLengthPublicKeyType();
    var nBytesKey = getLengthKey();

    var nBytesPublicKeyTypeMarshal = getLengthPublicKeyTypeMarshal();
    var nBytesPublicKeyValueMarshal = getLengthPublicKeyValueMarshal();
    var nBytesPublicKey = nBytesPublicKeyTypeMarshal + nBytesPublicKeyValueMarshal;
    var nBytesPublicKeyMarshal = getLengthStringMarshal(nBytesPublicKey);

    signal input authInfo_signerInfos_publicKey_type[nBytesPublicKeyType];
    signal input authInfo_signerInfos_publicKey_key[nBytesKey];
    
    signal output out[nBytesPublicKeyMarshal];
    signal output length;

    var i;

    component pktue = PublicKeyTypeUrlEncode();
    for(i = 0; i < nBytesPublicKeyType; i++) {
        pktue.in[i] <== authInfo_signerInfos_publicKey_type[i];
    }

    component pkve = PublicKeyValueEncode();
    for(i = 0; i < nBytesKey; i++) {
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

template PublicKeyValueEncode() {
    var prefixKey = getPrefixKey();
    var prefixValue = getPrefixValue();

    var nBytes = getLengthKey();
    var nBytesKeyMarshal = getLengthKeyMarshal();
    var nBytesPublicKeyValueMarshal = getLengthPublicKeyValueMarshal();

    signal input in[nBytes];
    
    signal output out[nBytesPublicKeyValueMarshal];
    signal output length;

    var i;

    component smKey = StringMarshal(nBytes);
    smKey.prefix <== prefixKey;
    for(i = 0; i < nBytes; i++) {
        smKey.in[i] <== in[i];
    }

    component smValue = StringMarshal(nBytesKeyMarshal);
    smValue.prefix <== prefixValue;
    for(i = 0; i < nBytesKeyMarshal; i++) {
        smValue.in[i] <== smKey.out[i];
    }

    for(i = 0; i < nBytesPublicKeyValueMarshal; i++) {
        out[i] <== smValue.out[i];
    }
    length <== smValue.length;
}

template PublicKeyTypeUrlEncode() {
    var prefixType = getPrefixPublicKeyType();

    var nBytes = getLengthPublicKeyType();
    var nBytesPublicKeyTypeMarshal = getLengthPublicKeyTypeMarshal();

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

function getPrefixPublicKey() {
    return 0xa;
}

function getPrefixValue() {
    return 0x12;
}

function getPrefixPublicKeyType() {
    return 0xa;
}

function getLengthPublicKeyType() {
    return 31;
}

function getPrefixKey() {
    return 0xa;
}

function getLengthKey() {
    return 33;
}

function getLengthPublicKeyTypeMarshal() {
    return getLengthStringMarshal(getLengthPublicKeyType());
}

function getLengthKeyMarshal() {
    return getLengthStringMarshal(getLengthKey());
}

function getLengthPublicKeyValueMarshal() {
    return getLengthStringMarshal(getLengthKeyMarshal());
}

function getLengthPublicKey() {
    return getLengthPublicKeyTypeMarshal() + getLengthPublicKeyValueMarshal();
}

function getLengthPublicKeyMarshal() {
    return getLengthStringMarshal(getLengthPublicKey());
}
