// SPDX-License-Identifier: GPL-3.0
pragma circom 2.0.0;
include "../../../../libs/utils/string.circom";
include "../../../../libs/utils/convert.circom";
include "../../../../libs/utils/shiftbytes.circom";

template MessageArrayEncode(nMessage, nBytesMessagesType, nBytesMessagesSender, nBytesMessagesContract, nBytesMessagesMSG) {
    
    var nBytesMessagesMarshal = getLengthMessagesMarshal(nBytesMessagesType, nBytesMessagesSender, nBytesMessagesContract, nBytesMessagesMSG);
    
    signal body_messages_type[nMessage][nBytesMessagesType];
    signal body_messages_sender[nMessage][nBytesMessagesSender];
    signal body_messages_contract[nMessage][nBytesMessagesContract];
    signal body_messages_msg[nMessage][nBytesMessagesMSG];

    signal output out[nMessage * nBytesMessagesMarshal];
    signal output length;

    var i;
    var j;
    var k;
    var len = 0;

    component eM[nMessage];
    for(i = 0; i < nMessage; i++) {
        eM[i] = MessageEncode(nBytesMessagesType, nBytesMessagesSender, nMessageContract, nMessageMSG);
        for(j = 0; j < nBytesMessagesType; j++) {
            eM[i].body_messages_type[j] <== body_messages_type[i][j];
        }

        for(j = 0; j < nBytesMessagesSender; j++) {
            eM[i].body_messages_sender[j] <== body_messages_sender[i][j];
        }

        for(j = 0; j < nBytesMessagesContract; j++) {
            eM[i].body_messages_contract[j] <== body_messages_contract[i][j];
        }

        for(j = 0; j < nBytesMessagesMSG; j++) {
            eM[i].body_messages_msg[j] <== body_messages_msg[i][j];
        }
    }

    component pbaot = PutBytesArrayOnTop(nMessage, nBytesMessagesMarshal);
    for(i = 0; i < nMessage; i++) {
        for(j = 0; j < nBytesMessagesMarshal; j++) {
            pbot.in[i][j] <== eM[i].out[j];
        }
        pbaot.real_length <== eM[i].length;
    }

    for(i = 0; i < nMessage * nBytesMessagesMarshal; i++) {
        out[i] <== pbaot.out[i];
    }

    length <== pbaot.length;
}

template MessageEncode(nBytesMessagesType, nBytesMessagesSender, nBytesMessagesContract, nBytesMessagesMSG) {
    var prefixMessage = 0xa;

    var nBytesMessagesValueMarshal = getLengthMessagesValueMarshal( nBytesMessagesSender, nBytesMessagesContract, nBytesMessagesMSG);
    var nBytesMessagesTypeMarshal = getLengthMessagesTypeMarshal(nBytesMessagesType);

    var nBytesMessages = nBytesMessagesValueMarshal + nBytesMessagesTypeMarshal;
    var nBytesMessagesMarshal = getLengthStringMarshal(nBytesMessages);

    signal body_messages_type[nBytesMessagesType];
    signal body_messages_sender[nBytesMessagesSender];
    signal body_messages_contract[nBytesMessagesContract];
    signal body_messages_msg[nBytesMessagesMSG];

    //3 = 1 + nMessage_bytes
    signal output out[nBytesMessagesMarshal];
    signal output length;

    var i;
    var j;
    var cnt = 0;

    component emtu = MessageTypeUrlEncode(nBytesMessagesType);
    for(i = 0; i < nBytesMessagesType; i++) {
        emtu.in[i] <== body_messages_type;
    }

    component emv = MessageValueEncode(nBytesMessagesSender, nMessageContract, nMessageMSG);
    for(i = 0; i < nBytesMessagesSender; i++) {
        emv.body_messages_sender[i] <== body_messages_sender[i];
    }

    for(i = 0; i < nBytesMessagesContract; i++) {
        emv.body_messages_contract[i] <== body_messages_contract[i];
    }

    for(i = 0; i < nBytesMessagesMSG; i++) {
        emv.body_messages_msg[i] <== body_messages_msg[i];
    }

    component pbot = PutBytesOnTop(nBytesMessagesTypeMarshal, nBytesMessagesValueMarshal);
    for(i = 0; i < nBytesMessagesTypeMarshal; i++) {
        pbot.s1[i] <== emtu.out[i];
    }
    pbot.idx <== emtu.length;
    for(i = 0; i < nBytesMessagesValueMarshal; i++) {
        pbot.s2[i] <== emv.out[i];
    }

    component sm = StringMarshal(nBytesMessages);
    sm.prefix <== prefixMessage;
    for(i = 0; i < nBytesMessages; i++) {
        sm.in[i] <== pbot.out[i];
    }

    for(i = 0; i < nBytesMessagesMarshal; i++) {
        out[i] <== sm.out[i];
    }
    length <== sm.length;
}

template MessageValueEncode(nBytesMessagesSender, nMessageContract, nBytesMessagesMSG) {
    var prefixSender = 0xa;
    var prefixContract = 0x12;
    var prefixMSG = 0x1a;
    var prefixValue = 0x12;

    var nBytesMessagesSenderMarshal = getLengthStringMarshal(nBytesMessagesSender);
    var nBytesMessagesContractMarshal = getLengthStringMarshal(nBytesMessagesContract);
    var nBytesMessagesMSGMarshal = getLengthStringMarshal(nBytesMessagesMSG);

    var nBytesMessageValue = nBytesMessagesSenderMarshal + nBytesMessagesContractMarshal + nBytesMessagesMSGMarshal;
    var nBytesMessagesValueMarshal = getLengthStringMarshal(nBytesMessageValue);

    signal body_messages_sender[nBytesMessagesSender];
    signal body_messages_contract[nBytesMessagesContract];
    signal body_messages_msg[nBytesMessagesMSG];

    // (nBytesMessagesSender + 2 + nBytesMessagesContract + 2 + nBytesMessagesMSG + 1 + max_len_msg_byte + 1 + max_len_value_byte)
    signal output out[nBytesMessagesValueMarshal];
    signal output length;

    var i;
    var j;

    component csm = ConcatStringMarshal(nBytesMessagesSender, nMessageContract);
    csm.prefix1 <== prefixSender;
    for(i = 0; i < nBytesMessagesSender; i++) {
        csm.s1[i] <== body_messages_sender[i];
    }
    csm.prefix2 <== prefixContract;
    for(i = 0; i < nBytesMessagesContract; i++) {
        csm.s2[i] <== body_messages_contract[i];
    }

    component smMSG = StringMarshal(nBodyMessagesMSG);
    smMSG.prefix <== prefixMSG;
    for(i = 0; i < nBodyMessagesMSG; i++) {
        smMSG.in[i] <== body_messages_msg[i];
    }

    component pbot = PutBytesOnTop(nBytesMessagesSenderMarshal + nBytesMessagesContractMarshal, nBytesMessagesMSGMarshal);
    for(i = 0; i < nBytesMessagesSenderMarshal + nBytesMessagesContractMarshal; i++) {
        pbot.s1[i] <== csm.out[i];
    }
    pbot.idx <== csm.length;
    for(i = 0; i < nBytesMessagesMSGMarshal; i++) {
        pbot.s2[i] <== smMSG.out[i];
    }

    component smValue = StringMarshal(nBytesMessagesValue);
    smValue.prefix <== prefixValue;
    for(i = 0; i < nBytesMessagesValue; i++) {
        smValue.in[i] <== pbot.out[i];
    }

    for(i = 0; i < nBytesMessagesValueMarshal; i++) {
        out[i] <== smValue.out[i];
    }
    length <== smValue.length;
}

template MessageTypeUrlEncode(nBytes) {
    var prefixType = 0xa;

    var nBytesMessagesTypeMarshal = getLengthMessagesTypeMarshal(nBytes);

    signal input in[nBytes];
    signal output out[nBytesMessagesTypeMarshal];
    signal output length;

    var i;
    
    component sm = StringMarshal(nBytes);
    sm.prefix <== prefixType;
    for(i = 0; i < nBytes; i++) {
        sm.in[i] <== in[i];
    }

    for(i = 0; i < nBytesMessagesTypeMarshal; i++) {
        out[i] <== sm.out[i];
    }
    
    length <== sm.length;
}

function getLengthMessagesValue(nBytesMessagesSender, nBytesMessagesContract, nBytesMessagesMSG) {
    return getLengthStringMarshal(nBytesMessagesSender) + getLengthStringMarshal(nBytesMessagesContract) + getLengthStringMarshal(nBytesMessagesMSG);
}

function getLengthMessagesValueMarshal(nBytesMessagesSender, nBytesMessagesContract, nBytesMessagesMSG) {
    var nBytesValue = getLengthMessagesValue(nBytesMessagesSender, nBytesMessagesContract, nBytesMessagesMSG);
    return getLengthStringMarshal(nBytesValue)
}

function getLengthMessagesTypeMarshal(nBytesMessagesType) {
    return getLengthStringMarshal(nBytesMessagesType);
}

function getLengthMessages(nBytesMessagesType, nBytesMessagesSender, nBytesMessagesContract, nBytesMessagesMSG) {
    return getLengthMessagesTypeMarshal(nBytesMessagesType) + getLengthMessagesValueMarshal(nBytesMessagesSender, nBytesMessagesContract, nBytesMessagesMSG); 
}

function getLengthMessagesMarshal(nBytesMessagesType, nBytesMessagesSender, nBytesMessagesContract, nBytesMessagesMSG) {
    var nBytesMessage = getLengthMessages(nBytesMessagesType, nBytesMessagesSender, nBytesMessagesContract, nBytesMessagesMSG); 
    return getLengthStringMarshal(nBytesMessage);
}