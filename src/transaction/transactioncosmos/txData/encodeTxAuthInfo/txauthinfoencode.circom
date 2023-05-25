// SPDX-License-Identifier: GPL-3.0
pragma circom 2.0.0;
include "../../../../libs/utils/address.circom";
include "../../../../libs/utils/string.circom";
include "../../../../libs/utils/convert.circom";
include "../../../../libs/utils/shiftbytes.circom";
include "./encodeFee/feeencode.circom";
include "./encodeFee/encodeAmount/amountencode.circom";
include "./encodeFee/encodeGasLimit/gaslimitencode.circom";
include "./encodeSignerInfo/encodeModeInfo/modeinfoencode.circom";
include "./encodeSignerInfo/encodePublicKey/publickeyencode.circom";
include "./encodeSignerInfo/encodeSequence/sequenceencode.circom";
include "./encodeSignerInfo/signerinfoencode.circom";

template AuthInfoEncode() {
    var prefixAuthInfo = 0x12;

    var nSignerInfos = getNSignerInfos();
    var nBytesPublicKeyType = getLengthPublicKeyType();
    var nBytesKey = getLengthKey();
    var nAmount = getNAmount();

    var nBytesFeeDenom = getLengthFeeDenom();
    var nBytesFeeAmount = getLengthFeeAmount();
    var nBytesSignerInfoMarshal = getLengthSignerInfoMarshal();
    var nBytesFeeMarshal = getLengthFeeMarshal();
    var nBytesAuthInfo = nBytesSignerInfoMarshal + nBytesFeeMarshal;
    var nBytesAuthInfoMarshal = getLengthStringMarshal(nBytesAuthInfo);

    signal input authInfo_signerInfos_publicKey_type[nSignerInfos][nBytesPublicKeyType];
    signal input authInfo_signerInfos_publicKey_key[nSignerInfos][nBytesKey];
    signal input authInfo_signerInfos_modeInfo[nSignerInfos];
    signal input authInfo_signerInfos_sequence[nSignerInfos];
    signal input authInfo_fee_amount_denom[nAmount][nBytesFeeDenom];
    signal input authInfo_fee_amount_amount[nAmount][nBytesFeeAmount];
    signal input authInfo_fee_gasLimit;

    signal output out[nBytesAuthInfoMarshal];
    signal output length;

    var i;
    var j;

    component siae = SignerInfosArrayEncode();
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

    component fe = FeeEncode();
    for(i = 0; i < nAmount; i++) {
        for(j = 0; j < nBytesFeeDenom; j++) {
            fe.authInfo_fee_amount_denom[i][j] <== authInfo_fee_amount_denom[i][j];
        }
        for(j = 0; j < nBytesFeeAmount; j++) {
            fe.authInfo_fee_amount_amount[i][j] <== authInfo_fee_amount_amount[i][j];
        }
    }
    fe.authInfo_fee_gasLimit <== authInfo_fee_gasLimit;

    component pbot = PutBytesOnTop(nBytesSignerInfoMarshal, nBytesFeeMarshal);
    for(i = 0; i < nBytesSignerInfoMarshal; i++) {
        pbot.s1[i] <== siae.out[i];
    }
    pbot.idx <== siae.length;
    for(i = 0; i < nBytesFeeMarshal; i++) {
        pbot.s2[i] <== fe.out[i];
    }

    component sm = StringMarshal(nBytesAuthInfo);
    sm.prefix <== prefixAuthInfo;
    for(i = 0; i < nBytesAuthInfo; i++) {
        sm.in[i] <== pbot.out[i];
    }

    for(i = 0; i < nBytesAuthInfoMarshal; i++) {
        out[i] <== sm.out[i];
    }
    length <== sm.length;
}

template ExtractAuthInfos() {
    var nBytesAuthInfoMarshal = getLengthAuthInfoMarshal();
    var nBytesKey = getLengthKey();

    var key_start = 6 + getLengthPublicKeyType() + 4;

    signal input in[nBytesAuthInfoMarshal];
    signal output out;

    var i;
    
    component keyAddress = CalculateAddressBytes(nBytesKey);
    for(i = 0; i < nBytesKey; i++) {
        keyAddress.in[i] <== in[i + key_start];
    }
    out <== keyAddress.out;
}

function getLengthAuthInfo() {
    return getLengthSignerInfosMarshal() + getLengthFeeMarshal();
}

function getLengthAuthInfoMarshal() {
    return getLengthStringMarshal(getLengthAuthInfo());
}








