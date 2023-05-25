// SPDX-License-Identifier: GPL-3.0
pragma circom 2.0.0;

include "convert.circom";
include "string.circom";
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

template PutBytesOnTop(nBytes1, nBytes2) {
    signal input s1[nBytes1];
    signal input s2[nBytes2];
    signal input idx;
    
    signal output out[nBytes1 + nBytes2];

    var i;
    var j;

    component rb = CopyBytesToEmptyString(nBytes1 + nBytes2, nBytes2);
    for(i = 0; i < nBytes2; i++) {
        rb.in[i] <== s2[i];
    }
    rb.startIndex <== idx;

    component flags[nBytes1 + nBytes2];
    component sw[nBytes1 + nBytes2];

    for(i = 0; i < nBytes1; i++) {
        flags[i] = LessEqThan(12);
        flags[i].in[0] <== idx;
        flags[i].in[1] <== i; 

        sw[i] = Switcher();
        sw[i].sel <== flags[i].out;
        sw[i].L <== s1[i];
        sw[i].R <== rb.out[i];
        
        out[i] <== sw[i].outL;
    }

    for(i = nBytes1; i < nBytes1 + nBytes2; i++) {
        flags[i] = LessEqThan(12);
        flags[i].in[0] <== i; 
        flags[i].in[1] <== nBytes2 + idx;

        sw[i] = Switcher();
        sw[i].sel <== flags[i].out;
        sw[i].L <== 0;
        sw[i].R <== rb.out[i];
        out[i] <== sw[i].outL;
    }

}

template PutBytesArrayOnTop(nArrays, nBytes) {
    signal input in[nArrays][nBytes];
    signal input real_length[nArrays];
    
    signal output out[nArrays * nBytes];
    signal output length;

    var i;
    var j;

    component left;
    component right;
    component parrent;

    if(nArrays == 1) {
        for(i = 0; i < nBytes; i++) {
            out[i] <== in[0][i];
        }
        length <== real_length[0];
    } else {
        var k = getSplitPoint(nArrays);
        left = PutBytesArrayOnTop(k, nBytes);
        for(i = 0; i < k; i++) {
            for(j = 0; j < nBytes; j++) {
                left.in[i][j] <== in[i][j];
            }
            left.real_length[i] <== real_length[i];
        }

        right = PutBytesArrayOnTop(nArrays - k, nBytes);
        for(i = k; i < nArrays; i++) {
            for(j = 0; j < nBytes; j++) {
                right.in[i-k][j] <== in[i][j];
            }
            right.real_length[i-k] <== real_length[i];
        }

        parrent = PutBytesOnTop(k * nBytes, (nArrays - k) * nBytes);
        for(i = 0; i < k * nBytes; i++) {
            parrent.s1[i] <== left.out[i];
        }
        parrent.idx <== left.length;
        for(i = 0; i < (nArrays - k) * nBytes; i++) {
            parrent.s2[i] <== right.out[i];
        }

        for(i = 0; i < nArrays * nBytes; i++) {
            out[i] <== parrent.out[i];
        }
        length <== left.length + right.length;
    }
}

function getSplitPoint(nBytes) {
    var i = 1;
    for(i = 1; i * 2 < nBytes; i *= 2) {
        
    }

    return i;
}

