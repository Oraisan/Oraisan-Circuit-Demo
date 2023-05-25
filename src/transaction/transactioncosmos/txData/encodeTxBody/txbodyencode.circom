// SPDX-License-Identifier: GPL-3.0
pragma circom 2.0.0;
include "../../../../libs/utils/string.circom";
include "../../../../libs/utils/address.circom";
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

template ExtractBody(nBytesBodyMarshal) {

    var nBytesMessagesSender = getLengthMessagesSender();
    var nBytesMessagesContract = getLengthMessagesContract();

    var sender_start = 8 + getLengthMessagesType() + 5;
    var contract_start = sender_start + nBytesMessagesSender + 2;
    var root_deposit_start = contract_start + nBytesMessagesContract + 3 + 32;
    signal input in[nBytesBodyMarshal];
    signal output sender;
    signal output contract;
    signal output depositRoot;

    var i;

    component sAddress = CalculateAddressBytes(nBytesMessagesSender);
    for(i = 0; i < nBytesMessagesSender; i++) {
        sAddress.in[i] <== in[i + sender_start];
    }

    component sContract = CalculateAddressBytes(nBytesMessagesContract);
    for(i = 0; i < nBytesMessagesContract; i++) {
        sContract.in[i] <== in[i + contract_start];
    }

    component dfib = DeleteFromInvalidBytes(77);
    for(i = 0; i < 77; i++) {
        dfib.in[i] <== in[root_deposit_start + i];
    }

    component cabtn = ConvertAsciiBytesToNum(77);
    for(i = 0; i < 77; i++) {
        cabtn.in[i] <== dfib.out[i];
    }
    cabtn.length <== dfib.length;


    sender <== sAddress.out;
    contract <== sContract.out;
    depositRoot <== cabtn.out;
}


function getLengthBody(nBytesMessagesMSG) {
    return getNMessages() * getLengthMessagesMarshal(nBytesMessagesMSG);
}

function getLengthBodyMarshal(nBytesMessagesMSG) {
    return getLengthStringMarshal(getLengthBody(nBytesMessagesMSG));
}