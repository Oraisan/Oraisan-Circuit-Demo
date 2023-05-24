// SPDX-License-Identifier: GPL-3.0
pragma circom 2.0.0;
include "../../../libs/utils/string.circom";
include "./encodeTxMessage/txmessageencode.circom";

template EncodeBody(nBytesMessagesMSG) {
    var prefixTxBody = 0xa;
    
    var nMessage = getNMessages();
    var nBytesMessagesType = getLengthMessagesType();
    var nBytesMessagesSender = getLengthMessagesSender();
    var nBytesMessagesContract = getLengthMessagesContract();
    var nBytesBody = getLengthBody(nBytesMessagesMSG);
    var nBytesBodyMarshal = getLengthStringMarshal(nBytesBody);

    signal input body_messages_type[nMessage][nBytesMessagesType];
    signal input body_messages_sender[nMessage][nBytesMessagesSender];
    signal input body_messages_contract[nMessage][nBytesMessagesContract];
    signal input body_messages_msg[nMessage][nBytesMessagesMSG];
    // signal input body_memo;
    // signal input body_timeoutHeight;
    // signal input body_extensionOptions[nExtensionOptions];
    // signal input body_nonCriticalExtensionOptions[nNonCriticalExtensionOptions];

    signal output out[nBytesBodyMarshal];
    signal output length;

    var i;
    var j;

    component ema = MessageArrayEncode(nBytesMessagesMSG);
    for(i = 0; i < nMessage; i++) {
        for(j = 0; j < nBytesMessagesType; j++) {
            ema.body_messages_type[i][j] <== body_messages_type[i][j];
        }

        for(j = 0; j < nBytesMessagesSender; j++) {
            ema.body_messages_sender[i][j] <== body_messages_sender[i][j];
        }

        for(j = 0; j < nBytesMessagesContract; j++) {
            ema.body_messages_contract[i][j] <== body_messages_contract[i][j];
        }

        for(j = 0; j < nBytesMessagesMSG; j++) {
            ema.body_messages_msg[i][j] <== body_messages_msg[i][j];
        }
    }

    component sm = StringMarshal(nBytesBody);
    sm.prefix <== prefixTxBody;
    for(i = 0; i < nBytesBody; i++) {
        sm.in[i] <== ema.out[i];
    }

    for(i = 0; i < nBytesBodyMarshal; i++) {
        out[i] <== sm.out[i];
    }
    length <== sm.length;
}

function getLengthBody(nBytesMessagesMSG) {
    return getNMessages() * getLengthMessagesMarshal(nBytesMessagesMSG);
}

function getLengthBodyMarshal(nBytesMessagesMSG) {
    return getLengthStringMarshal(getLengthBody(nBytesMessagesMSG));
}