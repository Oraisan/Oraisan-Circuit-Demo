// SPDX-License-Identifier: GPL-3.0
pragma circom 2.0.0;
include "../txmessageencode.circom";

template MessageArrayEncodeVerifier(nMessage, nBytesMessagesMSG) {
    var nBytesMessagesType = getLengthMessagesType();
    var nBytesMessagesSender = getLengthMessagesSender();
    var nBytesMessagesContract = getLengthMessagesContract();
    
    var nBytesMessagesMarshal = getLengthMessagesMarshal(nBytesMessagesMSG);
    
    signal input body_messages_type[nMessage][nBytesMessagesType];
    signal input body_messages_sender[nMessage][nBytesMessagesSender];
    signal input body_messages_contract[nMessage][nBytesMessagesContract];
    signal input body_messages_msg[nMessage][nBytesMessagesMSG];

    signal input out[nMessage * nBytesMessagesMarshal];

    var i;
    var j;
    component mae = MessageArrayEncode(nMessage, nBytesMessagesMSG);
    for(i = 0; i < nMessage; i++) {
        for(j = 0; j < nBytesMessagesType; j++) {
            mae.body_messages_type[i][j] <== body_messages_type[i][j];
        }
        for(j = 0; j < nBytesMessagesSender; j++) {
            mae.body_messages_sender[i][j] <== body_messages_sender[i][j];
        }
        for(j = 0; j < nBytesMessagesContract; j++) {
            mae.body_messages_contract[i][j] <== body_messages_contract[i][j];
        }
        for(j = 0; j < nBytesMessagesMSG; j++) {
            mae.body_messages_msg[i][j] <== body_messages_msg[i][j];
        }
    }

    for(i = 0; i < nMessage * nBytesMessagesMarshal; i++) {
        mae.out[i] === out[i];
        log(i, mae.out[i]);
    }
    log(mae.length);
}


component main = MessageArrayEncodeVerifier(1, 124);