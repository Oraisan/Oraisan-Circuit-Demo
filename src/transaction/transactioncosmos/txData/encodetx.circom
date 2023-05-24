// SPDX-License-Identifier: GPL-3.0
pragma circom 2.0.0;
include "../../libs/utils/string.circom";
include "../../libs/utils/convert.circom";
include "../../libs/utils/shiftbytes.circom";
include "./encodeTxBody/txbodyencode.circom";
include "./encodeTxAuthInfo/txauthinfoencode.circom";
include "./encodeSignatures/signaturesencode.circom";

template TransactionEncode(nBytesMessagesMSG) {

    var nMessage = getNMessages();
    var nBytesMessagesType = getLengthMessagesType();
    var nBytesMessagesSender = getLengthMessagesSender();
    var nBytesMessagesContract = getLengthMessagesContract();
    var nBytesBodyMarshal = getLengthBodyMarshal(nBytesMessagesMSG);

    var nAmount = getNAmount();
    var nBytesFeeDenom = getLengthFeeDenom();
    var nBytesFeeAmount = getLengthFeeAmount();

    var nSignerInfos = getNSignerInfos();
    var nBytesPublicKeyType = getLengthPublicKeyType();
    var nBytesKey = getLengthKey();

    var nBytesAuthInfoMarshal = getLengthAuthInfoMarshal();

    
    var nSignatures = getNSignatures();
    var nBytesSignature = getLengthSignture();
    var nBytesSignatureMarshal = getLengthSignturesMarshal();

    var nBytesTx = nBytesBodyMarshal + nBytesAuthInfoMarshal + nBytesSignatureMarshal;

    signal input body_messages_type[nMessage][nBytesMessagesType];
    signal input body_messages_sender[nMessage][nBytesMessagesSender];
    signal input body_messages_contract[nMessage][nBytesMessagesContract];
    signal input body_messages_msg[nMessage][nBytesMessagesMSG];
    // signal input body_memo;
    // signal input body_timeoutHeight;
    // signal input body_extensionOptions[nExtensionOptions];
    // signal input body_nonCriticalExtensionOptions[nNonCriticalExtensionOptions];

    signal input authInfo_signerInfos_publicKey_type[nSignerInfos][nBytesPublicKeyType];
    signal input authInfo_signerInfos_publicKey_key[nSignerInfos][nBytesKey];
    signal input authInfo_signerInfos_modeInfo[nSignerInfos];
    signal input authInfo_signerInfos_sequence[nSignerInfos];
    signal input authInfo_fee_amount_denom[nAmount][nBytesFeeDenom];
    signal input authInfo_fee_amount_amount[nAmount][nBytesFeeAmount];
    signal input authInfo_fee_gasLimit;
    // signal input authInfo_payer;
    // signal input authInfo_grenter;

    signal input signatures[nSignatures][nBytesSignature];

    signal output out[nBytesTx];
    signal output length;

    var i;
    var j;
    component eb = EncodeBody(nBytesMessagesMSG);
    for(i = 0; i < nMessage; i++) {
        for(j = 0; j < nBytesMessagesType; j++) {
            eb.body_messages_type[i][j] <== body_messages_type[i][j];
        }
        for(j = 0; j < nBytesMessagesSender; j++) {
            eb.body_messages_sender[i][j] <== body_messages_sender[i][j];
        }
        for(j = 0; j < nBytesMessagesContract; j++) {
            eb.body_messages_contract[i][j] <== body_messages_contract[i][j];
        }
        for(j = 0; j < nBytesMessagesMSG; j++) {
            eb.body_messages_msg[i][j] <== body_messages_msg[i][j];
        }
    }

    component aie = AuthInfoEncode();
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

    component sae = SignaturesArrayEncode();
    for(i = 0; i < nSignatures; i++) {
        for(j = 0; j < nBytesSignature; j++) {
            sae.signatures[i][j] <== signatures[i][j];
        }
    }

    component pbAuthInfoOnTop = PutBytesOnTop(nBytesBodyMarshal, nBytesAuthInfoMarshal);
    for(i = 0; i < nBytesBodyMarshal; i++) {
        pbAuthInfoOnTop.s1[i] <== eb.out[i];
    }
    pbAuthInfoOnTop.idx <== eb.length;
    for(i = 0; i < nBytesAuthInfoMarshal; i++) {
        pbAuthInfoOnTop.s2[i] <== aie.out[i];
    }

    component pbSignaturesOnTop = PutBytesOnTop(nBytesBodyMarshal + nBytesAuthInfoMarshal, nBytesSignatureMarshal);
    for(i = 0; i < nBytesBodyMarshal + nBytesAuthInfoMarshal; i++) {
        pbSignaturesOnTop.s1[i] <== pbAuthInfoOnTop.out[i];
    }
    pbSignaturesOnTop.idx <== eb.length + aie.length;
    for(i = 0; i < nBytesSignatureMarshal; i++) {
        pbSignaturesOnTop.s2[i] <== sae.out[i];
    }

    for(i = 0; i < nBytesTx; i++) {
        out[i] <== pbSignaturesOnTop.out[i];
    }
    length <== eb.length + aie.length + sae.length;
}

function getLengthTx(nBytesMessagesMSG) {
    return getLengthBodyMarshal(nBytesMessagesMSG) + getLengthAuthInfoMarshal() + getLengthSignturesMarshal();
}