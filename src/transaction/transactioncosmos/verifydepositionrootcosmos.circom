// SPDX-License-Identifier: GPL-3.0
pragma circom 2.0.0;
include "./calculatetransactionvalue.circom";
include "../../AVL_Tree/avlverifier.circom";

template DepositionRootCosmosVerifier(nSiblings, nBytesMessagesMSG) {
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
    signal input body_messages_msg[nMessage][nBytesMessagesMSG]

    signal input authInfo_signerInfos_publicKey_type[nSignerInfos][nBytesPublicKeyType];
    signal input authInfo_signerInfos_publicKey_key[nSignerInfos][nBytesKey];
    signal input authInfo_signerInfos_modeInfo[nSignerInfos];
    signal input authInfo_signerInfos_sequence[nSignerInfos];
    signal input authInfo_fee_amount_denom[nAmount][nBytesFeeDenom];
    signal input authInfo_fee_amount_amount[nAmount][nBytesFeeAmount];
    signal input authInfo_fee_gasLimit;

    signal input signatures[nSignatures][nBytesSignature];

    signal input key;
    signal input dataHash[32];
    signal input siblingsRoot[nSiblings][32];

    var i;
    var j;

    component value = CalcuteTransactionvalue(nBytesMessagesMSG);
    for(i = 0; i < nMessage; i++) {
        for(j = 0; j < nBytesMessagesType; j++) {
            value.body_messages_type[i][j] <== body_messages_type[i][j];
        }
        for(j = 0; j < nBytesMessagesSender; j++) {
            value.body_messages_sender[i][j] <== body_messages_sender[i][j];
        }
        for(j = 0; j < nBytesMessagesContract; j++) {
            value.body_messages_contract[i][j] <== body_messages_contract[i][j];
        }
        for(j = 0; j < nBytesMessagesMSG; j++) {
            value.body_messages_msg[i][j] <== body_messages_msg[i][j];
        }
    }

    for(i = 0; i < nSignerInfos; i++) {
        for(j = 0; j < nBytesPublicKeyType; j++) {
            value.authInfo_signerInfos_publicKey_type[i][j] <== authInfo_signerInfos_publicKey_type[i][j];
        }
        for(j = 0; j < nBytesKey; j++) {
            value.authInfo_signerInfos_publicKey_key[i][j] <== authInfo_signerInfos_publicKey_key[i][j];
        }
        value.authInfo_signerInfos_modeInfo[i] <== authInfo_signerInfos_modeInfo[i];
        value.authInfo_signerInfos_sequence[i] <== authInfo_signerInfos_sequence[i];
    }

    for(i = 0; i < nAmount; i++) {
        for(j = 0; j < nBytesFeeDenom; j++) {
            value.authInfo_fee_amount_denom[i][j] <== authInfo_fee_amount_denom[i][j];
        }

        for(j = 0; j < nBytesFeeAmount; j++) {
            value.authInfo_fee_amount_amount[i][j] <== authInfo_fee_amount_amount[i][j];
        }
    }
    value.authInfo_fee_gasLimit <== authInfo_fee_gasLimit;

    for(i = 0; i < nSignatures; i++) {
        for(j = 0; j < nBytesSignature; j++) {
            value.signatures[i][j] <== signatures[i][j];
        }
    }

    component r = CalculateRootFromSiblings(nSiblings);
    for(j = 0; j < 32; j++) {
        for(i = 0; i < nSiblings; i++) {
            r.siblings[i][j] <== siblings[i][j];
        }
        r.value[i] <== value.out[i];
    }
    r.key <== key;
    
    for(i = 0; i < 32; i++) {
        dataHash[i] === r.root[i];
    }
}