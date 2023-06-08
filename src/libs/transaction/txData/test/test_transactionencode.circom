// SPDX-License-Identifier: GPL-3.0
pragma circom 2.0.0;
include "../encodetx.circom";
include "../../calculatedatahash.circom";
include "../../calculatetransactionhash.circom";

template TransactionEncodeVerifier(nBytesMessagesMSG) {
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

    signal input authInfo_signerInfos_publicKey_type[nSignerInfos][nBytesPublicKeyType];
    signal input authInfo_signerInfos_publicKey_key[nSignerInfos][nBytesKey];
    signal input authInfo_signerInfos_modeInfo[nSignerInfos];
    signal input authInfo_signerInfos_sequence[nSignerInfos];
    signal input authInfo_fee_amount_denom[nAmount][nBytesFeeDenom];
    signal input authInfo_fee_amount_amount[nAmount][nBytesFeeAmount];
    signal input authInfo_fee_gasLimit;

    signal input signatures[nSignatures][nBytesSignature];
    
    signal input out[nBytesTx];

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
    
    // for(i = 0; i < nBytesTx; i++) {
    //     te.out[i] === out[i];
    //     log(i, te.out[i]);
    // }
    // log(te.length);
}

template TransactionEncodeDefaultVerifier(nBytesBodyMarshal) {

    var nBytesAuthInfoMarshal = getLengthAuthInfoMarshal(); //109
    var nBytesSignatureMarshal = getLengthSignturesMarshal(); //66

    signal input txBody[nBytesBodyMarshal];
    signal input txAuthInfos[nBytesAuthInfoMarshal];
    signal input signatures[nBytesSignatureMarshal];

    signal input out[nBytesBodyMarshal + nBytesAuthInfoMarshal + nBytesSignatureMarshal];

    var i;
    var j;

    component te = TransactionEncodeDefault(nBytesBodyMarshal);
    for(i = 0; i < nBytesBodyMarshal; i++) {
        te.txBody[i] <== txBody[i];
    }

    for(i = 0; i < nBytesAuthInfoMarshal; i++) {
        te.txAuthInfos[i] <== txAuthInfos[i];
    }

    for(i = 0; i < nBytesSignatureMarshal; i++) {
        te.signatures[i] <== signatures[i];
    }
    
    for(i = 0; i < nBytesBodyMarshal + nBytesAuthInfoMarshal + nBytesSignatureMarshal; i++) {
        log(i, te.out[i]);
        te.out[i] === out[i];
    }
    log(te.length);
}

template TestDepositionRootCosmosDefaultVerifier(nSiblings, nBytesBodyMarshal) {

    var nBytesAuthInfoMarshal = getLengthAuthInfoMarshal(); //109
    var nBytesSignatureMarshal = getLengthSignturesMarshal(); //66

    signal input txBody[nBytesBodyMarshal];
    signal input txAuthInfos[nBytesAuthInfoMarshal];
    signal input signatures[nBytesSignatureMarshal];

    signal input key;
    signal input dataHash[32];
    signal input siblings[nSiblings][32];

    var i;
    var j;

    component te = CalculateDataHashFromTxData(nSiblings, nBytesBodyMarshal);
    for(i = 0; i < nBytesBodyMarshal; i++) {
        te.txBody[i] <== txBody[i];
    }

    for(i = 0; i < nBytesAuthInfoMarshal; i++) {
        te.txAuthInfos[i] <== txAuthInfos[i];
    }

    for(i = 0; i < nBytesSignatureMarshal; i++) {
        te.signatures[i] <== signatures[i];
    }
    
    te.key <== key;
    for(i = 0; i < nSiblings; i++) {
        for(j = 0; j < 32; j++) {
            te.siblings[i][j] <== siblings[i][j];
        }
    }

    for(i = 0; i < 32; i++) {
        dataHash[i] === te.out[i];
    }
}

template CalcuteTransactionDefaultHashVerifier(nSiblings) {

    signal input out[32];

    var i;
    var j;

    component leafs = HashLeaf(32);
    for(i = 0; i < 32; i++) {
        leafs.in[i] <== out[i];
    }

    // component r = CalculateRootFromSiblings(nSiblings);
    // for(j = 0; j < 32; j++) {
    //     for(i = 0; i < nSiblings; i++) {
    //         r.siblings[i][j] <== 0;
    //     }
    //     r.value[j] <== leafs.out[j];
    // }
    // r.key <== 0;

    for(i = 0; i < 32; i++) {
        log(i, leafs.out[i]);
    }
}
component main = CalcuteTransactionDefaultHashVerifier(2);