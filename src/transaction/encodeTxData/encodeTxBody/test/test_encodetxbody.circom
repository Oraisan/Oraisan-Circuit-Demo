// SPDX-License-Identifier: GPL-3.0
pragma circom 2.0.0;
include "../txbodyencode.circom";

template EncodeBodyVerifier(nMessage, nBytesMessagesMSG) {
    var nBytesMessagesType = getLengthMessagesType();
    var nBytesMessagesSender = getLengthMessagesSender();
    var nBytesMessagesContract = getLengthMessagesContract();
    var nBytesBodyMarshal = getLengthBodyMarshal(nMessage, nBytesMessagesMSG);
    
    signal input body_messages_type[nMessage][nBytesMessagesType];
    signal input body_messages_sender[nMessage][nBytesMessagesSender];
    signal input body_messages_contract[nMessage][nBytesMessagesContract];
    signal input body_messages_msg[nMessage][nBytesMessagesMSG];

    signal input out[nBytesBodyMarshal];

    var i;
    var j;
    component eb = EncodeBody(nMessage, nBytesMessagesMSG);
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

    for(i = 0; i < nBytesBodyMarshal; i++) {
        eb.out[i] === out[i];
        log(i, eb.out[i]);
    }
    log(eb.length);
}


component main = EncodeBodyVerifier(1, 124);