// SPDX-License-Identifier: GPL-3.0
pragma circom 2.0.0;
include "../../../../libs/utils/string.circom";
include "../../../../libs/utils/convert.circom";
include "../../../../libs/utils/shiftbytes.circom";

template MessageArrayEncode(nBytesMessagesMSG) {
    
    var nMessage = getNMessages();
    var nBytesMessagesType = getLengthMessagesType();
    var nBytesMessagesSender = getLengthMessagesSender();
    var nBytesMessagesContract = getLengthMessagesContract();
    
    var nBytesMessagesMarshal = getLengthMessagesMarshal(nBytesMessagesMSG);
    
    signal input body_messages_type[nMessage][nBytesMessagesType];
    signal input body_messages_sender[nMessage][nBytesMessagesSender];
    signal input body_messages_contract[nMessage][nBytesMessagesContract];
    signal input body_messages_msg[nMessage][nBytesMessagesMSG];

    signal output out[nMessage * nBytesMessagesMarshal];
    signal output length;

    var i;
    var j;
    var k;
    var len = 0;

    component eM[nMessage];
    for(i = 0; i < nMessage; i++) {
        eM[i] = MessageEncode(nBytesMessagesMSG);
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
            pbaot.in[i][j] <== eM[i].out[j];
        }
        pbaot.real_length[i] <== eM[i].length;
    }

    for(i = 0; i < nMessage * nBytesMessagesMarshal; i++) {
        out[i] <== pbaot.out[i];
    }

    length <== pbaot.length;
}

template MessageEncode(nBytesMessagesMSG) {
    var prefixMessage = 0xa;

    var nBytesMessagesType = getLengthMessagesType();
    var nBytesMessagesSender = getLengthMessagesSender();
    var nBytesMessagesContract = getLengthMessagesContract();
    var nBytesMessagesValueMarshal = getLengthMessagesValueMarshal(nBytesMessagesMSG);
    var nBytesMessagesTypeMarshal = getLengthMessagesTypeMarshal();

    var nBytesMessages = nBytesMessagesValueMarshal + nBytesMessagesTypeMarshal;
    var nBytesMessagesMarshal = getLengthStringMarshal(nBytesMessages);

    signal input body_messages_type[nBytesMessagesType];
    signal input body_messages_sender[nBytesMessagesSender];
    signal input body_messages_contract[nBytesMessagesContract];
    signal input body_messages_msg[nBytesMessagesMSG];

    //3 = 1 + nMessage_bytes
    signal output out[nBytesMessagesMarshal];
    signal output length;

    var i;
    var j;
    var cnt = 0;

    component emtu = MessageTypeUrlEncode();
    for(i = 0; i < nBytesMessagesType; i++) {
        emtu.in[i] <== body_messages_type[i];
    }

    component emv = MessageValueEncode(nBytesMessagesMSG);
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

template MessageValueEncode(nBytesMessagesMSG) {
    var prefixSender = 0xa;
    var prefixContract = 0x12;
    var prefixMSG = 0x1a;
    var prefixValue = 0x12;

    var nBytesMessagesSender = getLengthMessagesSender();
    var nBytesMessagesContract = getLengthMessagesContract();
    var nBytesMessagesSenderMarshal = getLengthStringMarshal(nBytesMessagesSender);
    var nBytesMessagesContractMarshal = getLengthStringMarshal(nBytesMessagesContract);
    var nBytesMessagesMSGMarshal = getLengthStringMarshal(nBytesMessagesMSG);

    var nBytesMessagesValue = nBytesMessagesSenderMarshal + nBytesMessagesContractMarshal + nBytesMessagesMSGMarshal;
    var nBytesMessagesValueMarshal = getLengthStringMarshal(nBytesMessagesValue);

    signal input body_messages_sender[nBytesMessagesSender];
    signal input body_messages_contract[nBytesMessagesContract];
    signal input body_messages_msg[nBytesMessagesMSG];

    // (nBytesMessagesSender + 2 + nBytesMessagesContract + 2 + nBytesMessagesMSG + 1 + max_len_msg_byte + 1 + max_len_value_byte)
    signal output out[nBytesMessagesValueMarshal];
    signal output length;

    var i;
    var j;

    component csm = ConcatStringMarshal(nBytesMessagesSender, nBytesMessagesContract);
    csm.prefix1 <== prefixSender;
    for(i = 0; i < nBytesMessagesSender; i++) {
        csm.s1[i] <== body_messages_sender[i];
    }
    csm.prefix2 <== prefixContract;
    for(i = 0; i < nBytesMessagesContract; i++) {
        csm.s2[i] <== body_messages_contract[i];
    }

    component smMSG = StringMarshal(nBytesMessagesMSG);
    smMSG.prefix <== prefixMSG;
    for(i = 0; i < nBytesMessagesMSG; i++) {
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

template MessageTypeUrlEncode() {
    var prefixType = 0xa;

    var nBytes = getLengthMessagesType();
    var nBytesMessagesTypeMarshal = getLengthMessagesTypeMarshal();

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

function getLengthMessagesValue(nBytesMessagesMSG) {
    return getLengthStringMarshal(getLengthMessagesSender()) + getLengthStringMarshal(getLengthMessagesContract()) + getLengthStringMarshal(nBytesMessagesMSG);
}

function getLengthMessagesValueMarshal(nBytesMessagesMSG) {
    var nBytesValue = getLengthMessagesValue(nBytesMessagesMSG);
    return getLengthStringMarshal(nBytesValue);
}

function getLengthMessagesTypeMarshal() {
    return getLengthStringMarshal(getLengthMessagesType());
}

function getLengthMessages(nBytesMessagesMSG) {
    return getLengthMessagesTypeMarshal() + getLengthMessagesValueMarshal(nBytesMessagesMSG); 
}

function getLengthMessagesMarshal(nBytesMessagesMSG) {
    var nBytesMessage = getLengthMessages(nBytesMessagesMSG); 
    return getLengthStringMarshal(nBytesMessage);
}

function getNMessages() {
    return 1;
}


function getLengthMessagesType() {
    return 36;
}

function getLengthMessagesSender() {
    return 43;
}

function getLengthMessagesContract() {
    return 43;
}
