// SPDX-License-Identifier: GPL-3.0
pragma circom 2.0.0;

include "convert.circom";
include "../../../node_modules/circomlib/circuits/bitify.circom";
include "../../../node_modules/circomlib/circuits/comparators.circom";
include "../../../node_modules/circomlib/circuits/switcher.circom";

template CopyBytesToEmptyString(nString, nBytes) {
    // assert(nString > nBytes);

    signal input in[nBytes];
    signal input startIndex;

    signal output out[nString];
    var i;
    var j;
    var sum;
    var k = startIndex;

    component sw[nString];
    component isEqual[nString];
    component isReplace[nString][nBytes];
    component swReplace[nString][nBytes];

    for(i = 0; i < nString; i++) {
        sum = 0;

        isEqual[i] = IsEqual();
        isEqual[i].in[0] <== k;
        isEqual[i].in[1] <== i;

        for(j = 0; j < nBytes; j++) {
            isReplace[i][j] = IsEqual();
            isReplace[i][j].in[0] <== j;
            isReplace[i][j].in[1] <== k - startIndex;

            swReplace[i][j] = Switcher();
            swReplace[i][j].sel <== isReplace[i][j].out;
            swReplace[i][j].L <== 0;
            swReplace[i][j].R <== in[j];

            sum += swReplace[i][j].outL;
        }

        sw[i] = Switcher();
        sw[i].sel <== isEqual[i].out;
        sw[i].L <== 0;
        sw[i].R <== sum;
        out[i] <== sw[i].outL;
        k += isEqual[i].out;
    }
}

template PutBytesOnTop(nBytesFirst, nBytesLast) {
    signal input s1[nBytesFirst];
    signal input s2[nBytesLast];
    signal input idx;
    
    signal output out[nBytesFirst + nBytesLast];

    var i;
    var j;

    component rb = CopyBytesToEmptyString(nBytesFirst + nBytesLast, nBytesLast);
    for(i = 0; i < nBytesLast; i++) {
        rb.in[i] <== s2[i];
    }
    rb.startIndex <== idx;

    component flags[nBytesFirst + nBytesLast];
    component sw[nBytesFirst + nBytesLast];

    for(i = 0; i < nBytesFirst; i++) {
        flags[i] = LessEqThan(8);
        flags[i].in[0] <== idx;
        flags[i].in[1] <== i; 

        sw[i] = Switcher();
        sw[i].sel <== flags[i].out;
        sw[i].L <== s1[i];
        sw[i].R <== rb.out[i];
        
        out[i] <== sw[i].outL;
    }

    for(i = nBytesFirst; i < nBytesFirst + nBytesLast; i++) {
        flags[i] = LessEqThan(8);
        flags[i].in[0] <== i; 
        flags[i].in[1] <== nBytesLast + idx;

        sw[i] = Switcher();
        sw[i].sel <== flags[i].out;
        sw[i].L <== 0;
        sw[i].R <== rb.out[i];
        out[i] <== sw[i].outL;
    }

}

template TrimSovBytes(nBytes) {
    signal input in[nBytes];

    signal output out[nBytes];
    signal output length;

    var i;
    var k = 0;
    var flags[nBytes];

    component isEmpty[nBytes];
    for(i = 0; i < nBytes; i++) {
        isEmpty[i] = IsEqual();
        isEmpty[i].in[0] <== in[i];
        isEmpty[i].in[1] <== (i < nBytes -1) ? 128 : 0;
        k += isEmpty[i].out;
    } 


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