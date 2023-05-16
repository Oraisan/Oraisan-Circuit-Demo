// SPDX-License-Identifier: GPL-3.0
pragma circom 2.0.0;
include "./encodeTxMessage/txmessageencode.circom";

template EncodeBody(nMessage, nBytesMessagesType, nBytesMessagesSender, nBytesMessagesContract, nBytesMessagesMSG) {
   
    var nBytesMessage = getLengthMessagesMarshal(nBytesMessagesType, nBytesMessagesSender, nBytesMessagesContract, nBytesMessagesMSG);

    signal body_messages_type[nMessage][nBytesMessagesType];
    signal body_messages_sender[nMessage][nBytesMessagesSender];
    signal body_messages_contract[nMessage][nBytesMessagesContract];
    signal body_messages_msg[nMessage][nBytesMessagesMSG];
    // signal body_memo;
    // signal body_timeoutHeight;
    // signal body_extensionOptions[nExtensionOptions];
    // signal body_nonCriticalExtensionOptions[nNonCriticalExtensionOptions];

    signal output out[nMessage * nBytesMessage];
    signal output length;

    var i;
    var j;

    component ema = MessageArrayEncode(nMessanMessage, nBytesMessagesType, nBytesMessagesSender, nBytesMessagesContract, nBytesMessagesMSG);
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

    for(i = 0; i < nMessage * nBytesMessage; i++) {
        out[i] <== ema.out[i];
    }

    length <== ema.length;
}

