// SPDX-License-Identifier: GPL-3.0
pragma circom 2.0.0;
include "../../../../../libs/utils/string.circom";
include "../../../../../libs/utils/convert.circom";
include "../../../../../libs/utils/shiftbytes.circom";
include "./encodeModeInfo/modeinfoencode.circom";
include "./encodePublicKey/publickeyencode.circom";
include "./encodeSequence/sequenceencode.circom";

template SignerInfosArrayEncodeDefault() {
    var prefixSignerInfos = getPrefixSignerInfos();

    // var nBytesPublicKeyType = getLengthPublicKeyType();
    var nBytesKey = getLengthKey();
    var nBytesPublicKeyMarshal = getLengthPublicKeyMarshal();
    var nBytesModeInfoMarshal = getLengthModeInfoMarshal();
    var nBytesSequenceMarshal = getLengthSequenceMarshal();

    var nBytesSignerInfoMarshal = getLengthSignerInfoMarshal();
    // signal input authInfo_signerInfos_publicKey_type[nBytesPublicKeyType];
    signal input authInfo_signerInfos_publicKey_key[nBytesKey];
    signal input authInfo_signerInfos_modeInfo;
    signal input authInfo_signerInfos_sequence;

    signal output out[nBytesSignerInfoMarshal];
    signal output length;

    var i;
    var j;

    component se = SequenceEncode();
    se.in <== authInfo_signerInfos_sequence;

    component mie = ModeInfoEncodeDefault();
    mie.in <== authInfo_signerInfos_modeInfo;

    component pke = PublicKeyEncodeDefault();
    for(i = 0; i < nBytesKey; i++) {
        pke.authInfo_signerInfos_publicKey_key[i] <== authInfo_signerInfos_publicKey_key[i];
    }

    out[0] <== prefixSignerInfos;
    out[1] <== se.length + mie.length + pke.length;
    for(i = 0; i < nBytesPublicKeyMarshal; i++) {
        out[i] <== pke.out[i];
    }
    for(i = 0; i < nBytesModeInfoMarshal; i++){
        out[i + nBytesPublicKeyMarshal] <== mie.out[i];
    }
    for(i = 0; i < nBytesSequenceMarshal; i++) {
        out[i + nBytesPublicKeyMarshal + nBytesModeInfoMarshal] <== se.out[i];
    }
    length <== se.length + mie.length + pke.length;
}

template SignerInfosArrayEncode() {

    var nSignerInfos = getNSignerInfos();
    var nBytesPublicKeyType = getLengthPublicKeyType();
    var nBytesKey = getLengthKey();

    var nBytesSignerInfoMarshal = getLengthSignerInfoMarshal();

    signal input authInfo_signerInfos_publicKey_type[nSignerInfos][nBytesPublicKeyType];
    signal input authInfo_signerInfos_publicKey_key[nSignerInfos][nBytesKey];
    signal input authInfo_signerInfos_modeInfo[nSignerInfos];
    signal input authInfo_signerInfos_sequence[nSignerInfos];

    signal output out[nSignerInfos * nBytesSignerInfoMarshal];
    signal output length;

    var i;
    var j;

    component sie[nSignerInfos];
    for(i = 0; i < nSignerInfos; i++) {
        sie[i] = SignerInfosEncode();
        for(j = 0; j < nBytesPublicKeyType; j++) {
            sie[i].authInfo_signerInfos_publicKey_type[j] <== authInfo_signerInfos_publicKey_type[i][j];
        }
        for(j = 0; j < nBytesKey; j++) {
            sie[i].authInfo_signerInfos_publicKey_key[j] <== authInfo_signerInfos_publicKey_key[i][j];
        }
        sie[i].authInfo_signerInfos_modeInfo <== authInfo_signerInfos_modeInfo[i];
        sie[i].authInfo_signerInfos_sequence <== authInfo_signerInfos_sequence[i];
    } 

    component pbaot = PutBytesArrayOnTop(nSignerInfos, nBytesSignerInfoMarshal);
    for(i = 0; i < nSignerInfos; i++) {
        for(j = 0; j < nBytesSignerInfoMarshal; j++) {
            pbaot.in[i][j] <== sie[i].out[j];
        }
        pbaot.real_length[i] <== sie[i].length;
    }

    for(i = 0; i < nSignerInfos * nBytesSignerInfoMarshal; i++) {
        out[i] <== pbaot.out[i];
    }
    length <== pbaot.length;
}

template SignerInfosEncode() {
    var prefixSignerInfos = getPrefixSignerInfos();

    var nBytesPublicKeyType = getLengthPublicKeyType();
    var nBytesKey = getLengthKey();

    var nBytesPublicKeyMarshal = getLengthPublicKeyMarshal();
    var nBytesModeInfoMarshal = getLengthModeInfoMarshal();
    var nBytesSequenceMarshal = getLengthSequenceMarshal();
    var nBytesSignerInfo = getLengthSignerInfo();
    var nBytesSignerInfoMarshal = getLengthStringMarshal(nBytesSignerInfo);

    signal input authInfo_signerInfos_publicKey_type[nBytesPublicKeyType];
    signal input authInfo_signerInfos_publicKey_key[nBytesKey];
    signal input authInfo_signerInfos_modeInfo;
    signal input authInfo_signerInfos_sequence;

    signal output out[nBytesSignerInfoMarshal];
    signal output length;

    var i;
    component se = SequenceEncode();
    se.in <== authInfo_signerInfos_sequence;

    component mie = ModeInfoEncode();
    mie.in <== authInfo_signerInfos_modeInfo;

    component pbsot = PutBytesOnTop(nBytesModeInfoMarshal, nBytesSequenceMarshal);
    for(i = 0; i < nBytesModeInfoMarshal; i++) {
        pbsot.s1[i] <== mie.out[i];
    }
    pbsot.idx <== mie.length;
    for(i = 0; i < nBytesSequenceMarshal; i++) {
        pbsot.s2[i] <== se.out[i];
    }
    
    component pke = PublicKeyEncode();
    for(i = 0; i < nBytesPublicKeyType; i++) {
        pke.authInfo_signerInfos_publicKey_type[i] <== authInfo_signerInfos_publicKey_type[i];
    }
    for(i = 0; i < nBytesKey; i++) {
        pke.authInfo_signerInfos_publicKey_key[i] <== authInfo_signerInfos_publicKey_key[i];
    }

    component pbot = PutBytesOnTop(nBytesPublicKeyMarshal, nBytesModeInfoMarshal + nBytesSequenceMarshal);
    for(i = 0; i < nBytesPublicKeyMarshal; i++) {
        pbot.s1[i] <== pke.out[i];
    }
    pbot.idx <== pke.length;
    for(i = 0; i < nBytesModeInfoMarshal + nBytesSequenceMarshal; i++) {
        pbot.s2[i] <== pbsot.out[i];
    }

    component sm = StringMarshal(nBytesSignerInfo);
    sm.prefix <== prefixSignerInfos;
    for(i = 0; i < nBytesSignerInfo; i++) {
        sm.in[i] <== pbot.out[i];
    }

    for(i = 0; i < nBytesSignerInfoMarshal; i++) {
        out[i] <== sm.out[i];
    }
    length <== sm.length;
}

function getPrefixSignerInfos() {
    return 0xa;
}

function getNSignerInfos() {
    return 1;
}

function getLengthSignerInfo() {
    return getLengthPublicKeyMarshal() + getLengthModeInfoMarshal() + getLengthSequenceMarshal();
}

function getLengthSignerInfoMarshal() {
    return getLengthStringMarshal(getLengthSignerInfo());
}

function getLengthSignerInfosMarshal() {
    return getNSignerInfos() * getLengthSignerInfoMarshal();
}
