// SPDX-License-Identifier: GPL-3.0
pragma circom 2.0.0;
include "../../../node_modules/circomlib/circuits/switcher.circom";
include "../../../node_modules/circomlib/circuits/comparators.circom";

template Length(nBytes) {
    signal input in[nBytes];
    signal output out;

    var i;
    var k = 0;

    component isEmpty[nBytes];
    component mayEmpty[nBytes];

    mayEmpty[nBytes - 1] = IsEqual();
    mayEmpty[nBytes - 1].in[0] <== in[nBytes - 1];
    mayEmpty[nBytes - 1].in[1] <== 0;

    isEmpty[nBytes - 1] = IsZero();
    isEmpty[nBytes - 1].in <== 1 - mayEmpty[nBytes - 1].out;
    
    k += isEmpty[nBytes - 1].out;
    
    for(i = nBytes - 2; i >= 0; i = i - 1) {
        mayEmpty[i] = IsEqual();
        mayEmpty[i].in[0] <== in[i];
        mayEmpty[i].in[1] <== 0;

        isEmpty[i] = IsZero();
        isEmpty[i].in  <== 1 - isEmpty[i + 1].out * mayEmpty[i].out;
        k += isEmpty[i].out;
    }

    out <== nBytes - k;
}

template AddLengthStringMarshal(nBytes) {
    var nSovBytes = getNumSovBytes(nBytes);

    signal input in[nBytes];
    signal output out[nBytes + nSovBytes];
    signal output length;
    
    var i;
    var j;

    component len_string = Length(nBytes);
    for(i = 0; i < nBytes; i++) {
        len_string.in[i] <== in[i];
    }

    component sntb = SovNumToBytes(nSovBytes);
    sntb.in <== len_string.out;

    component tsb = TrimSovBytes(nSovBytes);
    for(i = 0; i < nSovBytes; i++) {
        tsb.in[i] <== sntb.out[i];
    }

    component pbot = PutBytesOnTop(nSovBytes, nBytes);
    for(i = 0; i < nSovBytes; i++) {
        pbot.s1[i] <== tsb.out[i];
    }
    pbot.idx <== tsb.length;

    for(i = 0; i < nBytes; i++) {
        pbot.s2[i] <== in[i];
    }

    for(i = 0; i < nBytes + nSovBytes; i++) {
        out[i] <== pbot.out[i];
    }


    length <== tsb.length + len_string.out;
}

template StringMarshal(nBytes) {
    var nSovBytes = getNumSovBytes(nBytes);

    signal input prefix;
    signal input in[nBytes];
    signal output out[nBytes + nSovBytes + 1];
    signal output length;   

    var i;
    var j;

    component alm = AddLengthStringMarshal(nBytes);
    for(i = 0; i < nBytes; i++) {
        alm.in[i] <== in[i];
    }

    out[0] <== prefix;
    for(i = 0; i < nBytes + nSovBytes; i++) {
        out[i + 1] <== alm.out[i];
    }
    length <== 1 + alm.length;
}

template ConcatStringMarshal(nBytes1, nBytes2) {
    var nBytes1Marshal = getLengthStringMarshal(nBytes1);
    var nBytes2Marshal = getLengthStringMarshal(nBytes2);

    signal input prefix1;
    signal input s1[nBytes1];
    signal input prefix2;
    signal input s2[nBytes2];

    signal output out[nBytes1Marshal + nBytes2Marshal];
    signal output length;

    var i;
    var j;

    component smS1 = StringMarshal(nBytes1);
    smS1.prefix <== prefix1;
    for(i = 0; i < nBytes1; i++) {
        smS1.in[i] <== s1[i];
    }

    component smS2 = StringMarshal(nBytes2);
    smS2.prefix <== prefix2;
    for(i = 0; i < nBytes2; i++) {
        smS2.in[i] <== s2[i];
    }

    component pbot = PutBytesOnTop(nBytes1Marshal, nBytes2Marshal);
    for(i = 0; i < nBytes1Marshal; i++) {
        pbot.s1[i] <== smS1.out[i];
    }
    pbot.idx <== smS1.length;

    for(i = 0; i < nBytes2Marshal; i++) {
        pbot.s2[i] <== smS2.out[i];
    }
    
    for(i = 0; i < nBytes1Marshal + nBytes2Marshal; i++) {
        out[i] <== pbot.out[i];
    }
    length <== smS1.length + smS2.length;
}

template TrimSovBytes(nBytes) {
    // assert(nBytes == 0);

    signal input in[nBytes];

    signal output out[nBytes];
    signal output length;

    var i;
    var k = 0;
    var flags[nBytes];

    component isEmpty[nBytes];
    component mayEmpty[nBytes];

    mayEmpty[nBytes - 1] = IsEqual();
    mayEmpty[nBytes - 1].in[0] <== in[nBytes - 1];
    mayEmpty[nBytes - 1].in[1] <== 0;

    isEmpty[nBytes - 1] = IsZero();
    isEmpty[nBytes - 1].in <== 1 - mayEmpty[nBytes - 1].out;
    
    k += isEmpty[nBytes - 1].out;
    
    for(i = nBytes - 2; i >= 0; i = i - 1) {
        mayEmpty[i] = IsEqual();
        mayEmpty[i].in[0] <== in[i];
        mayEmpty[i].in[1] <== 128;

        isEmpty[i] = IsZero();
        isEmpty[i].in  <== 1 - isEmpty[i + 1].out * mayEmpty[i].out;
        k += isEmpty[i].out;
    }

    // for(i = 0; i < nBytes; i++) {
    //     isEmpty[i] = IsEqual();
    //     isEmpty[i].in[0] <== in[i];
    //     isEmpty[i].in[1] <== (i < nBytes -1) ? 128 : 0;
    //     k += isEmpty[i].out;
    // } 


    component isSW[nBytes];
    component swSB[nBytes];
    for(i = 0; i < nBytes; i++) {
        isSW[i] = LessThan(32);
        isSW[i].in[0] <== i + 1;
        isSW[i].in[1] <== nBytes - k;

        swSB[i] = SwitchSovByte();
        swSB[i].xor <== isSW[i].out;
        swSB[i].in <== in[i];

        out[i] <== swSB[i].out;
    }
    length <== nBytes - k;
}

function getNumSovBytes(nBytes) {
    var i = 1;
    var j = 1;
    for(i = 1; i * 128 < nBytes; i *= 128) {
        j++;
    }
    return j;
}

function getLengthStringMarshal(nBytes) {
    var nSovBytes = getNumSovBytes(nBytes);
    var length = 1 + nSovBytes + nBytes;
    // log("getLengthStringMarshal", nSovBytes, nBytes, length);
    return length;
}

template ConvertAsciiBytesToNum(nBytes) {
    assert(nBytes <= 77);

    signal input in[nBytes];
    signal input length;
    signal output out;

    var i ;
    var j = 0;
    var k = 1;
    component isGreater[nBytes];
    component sw[nBytes];
    component swSum[nBytes];
    for(i = nBytes - 1; i >= 0; i = i - 1) {
        isGreater[i] = GreaterEqThan(8);
        isGreater[i].in[0] <== i;
        isGreater[i].in[1] <== length;

        swSum[i] = Switcher();
        swSum[i].sel <== isGreater[i].out;
        swSum[i].L <== (in[i] - 48) * k;
        swSum[i].R <== 0;

        j += swSum[i].outL;

        sw[i] = Switcher();
        sw[i].sel <== isGreater[i].out;
        sw[i].L <== k * 10;
        sw[i].R <== k;
        k = sw[i].outL;
    }

    out <== j;
}

template DeleteFromInvalidBytes(nBytes) {
    signal input in[nBytes];
    signal output out[nBytes];
    signal output length;
    var i;
    var j = 0;
    component isNonExist[nBytes];


    component checkInvalid[nBytes];
    checkInvalid[0] = GreaterEqThan(8);
    checkInvalid[0].in[0] <== in[0];
    checkInvalid[0].in[1] <== 48;

    isNonExist[0] = IsZero();
    isNonExist[0].in <== 1 - checkInvalid[0].out;

    for(i = 1; i < nBytes; i++) {
        checkInvalid[i] = GreaterEqThan(8);
        checkInvalid[i].in[0] <== in[i];
        checkInvalid[i].in[1] <== 48;

        isNonExist[i] = IsZero();
        isNonExist[i].in <== 1 -  isNonExist[i - 1].out * checkInvalid[i].out;
    }

    component sw[nBytes];
    for(i = 0; i < nBytes; i++) {
        sw[i] = Switcher();
        sw[i].sel <== isNonExist[i].out;
        sw[i].L <== 48;
        sw[i].R <== in[i];
        out[i] <== sw[i].outL;
        j += isNonExist[i].out;
    }
     length <== j;
}