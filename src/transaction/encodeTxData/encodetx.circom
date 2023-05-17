// SPDX-License-Identifier: GPL-3.0
pragma circom 2.0.0;
include "../../libs/utils/string.circom";
include "../../libs/utils/convert.circom";
include "../../libs/utils/shiftbytes.circom";

template TransactionEncode(nBodyMessagesMSG) {
    var nMessage = 1;
    var nBytesMessagesType = 36;
    var nBytesMessagesSender = 43;
    var nBytesMessagesContract = 43;

    var nSignerInfos = 1;
    var nPublicKeyType = 31;
    var nPublicKey = 33;

    var nAmount;
    var nFeeDenom = 4; //orai
    var nFeeAmount = 1;

    var nSignatures = 64;

    signal body_messages_type[nMessage][nBytesMessagesType];
    signal body_messages_sender[nMessage][nBytesMessagesSender];
    signal body_messages_contract[nMessage][nBytesMessagesContract];
    signal body_messages_msg[nMessage][nBytesMessagesMSG];
    // signal body_memo;
    // signal body_timeoutHeight;
    // signal body_extensionOptions[nExtensionOptions];
    // signal body_nonCriticalExtensionOptions[nNonCriticalExtensionOptions];

    signal authInfo_signerInfos_publicKey_type[nSignerInfos][nPublicKeyType];
    signal authInfo_signerInfos_publicKey_key[nSignerInfos][nPublicKey];
    signal authInfo_signerInfos_modeInfo[nSignerInfos];
    signal authInfo_signerInfos_sequence[nSignerInfos];
    signal authInfo_fee_amount_denom[nAmount][nFeeDenom];
    signal authInfo_fee_amount_amount[nAmount][nFeeAmount];
    signal authInfo_fee_gasLimit;
    // signal authInfo_payer;
    // signal authInfo_grenter;

    signal signatures[nSignatures];
}

