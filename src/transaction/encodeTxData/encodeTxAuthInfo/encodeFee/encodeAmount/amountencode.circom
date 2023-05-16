// SPDX-License-Identifier: GPL-3.0
pragma circom 2.0.0;
include "../../../../../lib/utils/string.circom";
include "../../../../../lib/utils/convert.circom";
include "../../../../../lib/utils/shiftbytes.circom";

template AmountArrayEncode(nAmount, nBytesFeeDenom, nBytesFeeAmount) {
    var nBytesAmountMarshal = getLengthAmountMarshal(nBytesFeeDenom, nBytesFeeAmount);

    signal authInfo_fee_amount_denom[nAmount][nBytesFeeDenom];
    signal authInfo_fee_amount_amount[nAmount][nBytesFeeAmount];
    signal output out[nAmount * nBytesAmountMarshal];
    signal output length;

    var i;
    var j;

    component ae[nAmount];
    for(i = 0; i < nAmount; i++) {
        ae = AmountEncode(nBytesFeeDenom, nBytesFeeAmount);
        for(j = 0; j < nBytesFeeDenom; j++) {
            ae[i].authInfo_fee_amount_denom[j] <== authInfo_fee_amount_denom[i][j];
        }

        for(j = 0; j < nBytesFeeAmount; j++) {
            ae[i].authInfo_fee_amount_amount[j] <== authInfo_fee_amount_amount[i][j];
        }
    }

    component pbaot = PutBytesArrayOnTop(nAmount, nBytesAmountMarshal);
    for(i = 0; i < nAmount; i++) {
        for(j = 0; j < nBytesAmountMarshal; j++) {
            pbaot.in[i][j] <== ae[i].out[j];
        }
        pbaot.real_length[i] <== ae[i].length;
    }

    for(i = 0; i < nAmount * nBytesAmountMarshal; i++) {
        out[i] <== pbaot.out[i];
    }
    length <== pbaot.length;
}

template AmountEncode(nBytesFeeDenom, nBytesFeeAmount) {
    var prefixFeeAmount = 0x12;
    var prefixFeeDenom = 0xa;
    var prefixAmount = 0xa;

    var nBytesAmount = getLengthAmount(nBytesFeeDenom, nBytesFeeAmount);
    var nBytesFeeAmountMarshal = getLengthStringMarshal(nBytesFeeAmount);

    signal authInfo_fee_amount_denom[nBytesFeeDenom];
    signal authInfo_fee_amount_amount[nBytesFeeAmount];

    signal output out[nBytesFeeAmountMarshal];
    signal output length;

    var i;
    var j;

    component csm = ConcatStringMarshal(nBytesFeeDenom, nBytesFeeAmount);
    csm.prefix1 <== prefixFeeDenom;
    for(i = 0; i < nBytesFeeDenom; i++) {
        csm.s1[i] <== authInfo_fee_amount_denom[i];
    }
    csm.prefix2 <== prefixFeeAmount;
    for(i = 0; i < nBytesFeeAmount; i++) {
        csm.s2[i] <== authInfo_fee_amount_amount[i];
    }

    component sm = StringMarshal(nBytesAmount);
    sm.prefix <== prefixAmount;
    for(i = 0; i < nBytesAmount; i++) {
        sm.in[i] <== csm.out[i];
    }

    for(i = 0; i < nBytesFeeAmountMarshal; i++) {
        out[i] <== sm.out[i];
    }
    length <== sm.length;

}

function getLengthAmount(nBytesFeeDenom, nBytesFeeAmount) {
    return getLengthStringMarshal(nBytesFeeDenom) + getLengthStringMarshal(nBytesFeeAmount);
}

function getLengthAmountMarshal(nBytesFeeDenom, nBytesFeeAmount) {
    var nBytesFeeAmount = getLengthAmount(nBytesFeeDenom, nBytesFeeAmount);
    return getLengthStringMarshal(nBytesFeeAmount);
}