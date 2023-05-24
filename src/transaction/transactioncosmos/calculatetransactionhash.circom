// SPDX-License-Identifier: GPL-3.0
pragma circom 2.0.0;

include "./encodeTxData/encodetx.circom";
include "../../sha/sha256prepared.circom";

template CalcuteTransactionHash(nBytesMessagesMSG) {

    var nMessage = getNMessages();
    var nBytesMessagesType = getLengthMessagesType();
    var nBytesMessagesSender = getLengthMessagesSender();
    var nBytesMessagesContract = getLengthMessagesContract();
    
    var nAmount = getNAmount();
    var nBytesFeeDenom = getLengthFeeDenom();
    var nBytesFeeAmount = getLengthFeeAmount();

    var nSignerInfos = getNSignerInfos();
    var nBytesPublicKeyType = getLengthPublicKeyType();
    var nBytesKey = getLengthKey();

    var nSignatures = getNSignatures();
    var nBytesSignature = getLengthSignture();

    var nBytesTx = getLengthTx(nBytesMessagesMSG);

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

    signal input signatures[nSignatures][nBytesSignature];

    signal output out[32];

    var i;
    var j;
    component te = TransactionEncode(nBytesMessagesMSG);
    for(i = 0; i < nMessage; i++) {
        for(j = 0; j < nBytesMessagesType; j++) {
            te.body_messages_type[i][j] <== body_messages_type[i][j];
        }
        for(j = 0; j < nBytesMessagesSender; j++) {
            te.body_messages_sender[i][j] <== body_messages_sender[i][j];
        }
        for(j = 0; j < nBytesMessagesContract; j++) {
            te.body_messages_contract[i][j] <== body_messages_contract[i][j];
        }
        for(j = 0; j < nBytesMessagesMSG; j++) {
            te.body_messages_msg[i][j] <== body_messages_msg[i][j];
        }
    }

    for(i = 0; i < nSignerInfos; i++) {
        for(j = 0; j < nBytesPublicKeyType; j++) {
            te.authInfo_signerInfos_publicKey_type[i][j] <== authInfo_signerInfos_publicKey_type[i][j];
        }
        for(j = 0; j < nBytesKey; j++) {
            te.authInfo_signerInfos_publicKey_key[i][j] <== authInfo_signerInfos_publicKey_key[i][j];
        }
        te.authInfo_signerInfos_modeInfo[i] <== authInfo_signerInfos_modeInfo[i];
        te.authInfo_signerInfos_sequence[i] <== authInfo_signerInfos_sequence[i];
    }

    for(i = 0; i < nAmount; i++) {
        for(j = 0; j < nBytesFeeDenom; j++) {
            te.authInfo_fee_amount_denom[i][j] <== authInfo_fee_amount_denom[i][j];
        }

        for(j = 0; j < nBytesFeeAmount; j++) {
            te.authInfo_fee_amount_amount[i][j] <== authInfo_fee_amount_amount[i][j];
        }
    }
    te.authInfo_fee_gasLimit <== authInfo_fee_gasLimit;

    for(i = 0; i < nSignatures; i++) {
        for(j = 0; j < nBytesSignature; j++) {
            te.signatures[i][j] <== signatures[i][j];
        }
    }

    component hash = SHA256Message(nBytesTx);
    for(i = 0; i < nBytesTx; i++) {
        hash.in[i] <== te.out[i];
    }
    hash.length <== te.length;

    for(i = 0; i < 32; i++) {
        out[i] <== hash.out[i];
    }
}