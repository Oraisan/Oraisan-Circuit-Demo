// SPDX-License-Identifier: GPL-3.0
pragma circom 2.0.0;
include "../../../../lib/utils/string.circom";
include "../../../../lib/utils/convert.circom";
include "../../../../lib/utils/shiftbytes.circom";
include "./encodeAmount/amountencode.circom";
include "./encodeGasLimit/gaslimitencode.circom";

template FeeEncode(nAmount, nBytesFeeDenom, nBytesFeeAmount) {
    var prefixFee = 0x12;

    var nBytesAmountMarshal = getLengthAmountMarshal(nBytesFeeDenom, nBytesFeeAmount);
    var nBytesGasLimitMarshal = getLengthGasLimitMarshal();

    var nBytesFee = nBytesAmountMarshal * nAmount + nBytesGasLimitMarshal;
    var nBytesFeeMarshal = getLengthStringMarshal(nBytesFee);

    signal authInfo_fee_amount_denom[nAmount][nBytesFeeDenom];
    signal authInfo_fee_amount_amount[nAmount][nBytesFeeAmount];
    signal authInfo_fee_gasLimit;

    signal output out[nBytesFeeMarshal];
    signal output length;

    var i;
    var j;
    component aae = AmountArrayEncode(nAmount, nBytesFeeDenom, nBytesFeeAmount);
    for(i = 0; i < nAmount; i++) {
        for(j = 0; j < nBytesFeeDenom; j++) {
            aae.authInfo_fee_amount_denom[i][j] <== authInfo_fee_amount_denom[i][j];
        }

        for(j = 0; j < nBytesFeeAmount; j++) {
            aae.authInfo_fee_amount_amount[i][j] <== authInfo_fee_amount_amount[i][j];
        }
    }

    component gle = GasLimitEncode();
    gle.authInfo_fee_gasLimit <== authInfo_fee_gasLimit;

    component pbot = PutBytesOnTop(nBytesAmountMarshal * nAmount, nBytesGasLimitMarshal);
    for(i = 0; i < nBytesAmountMarshal * nAmount; i++) {
        pbot.s1[i] <== aae.out[i];
    }
    pbot.idx <== aae.length;
    for(i = 0; i < nBytesGasLimitMarshal; i++) {
        pbot.s2[i] <== gle.out[i];
    }

    component sm = StringMarshal(nBytesFee);
    sm.prefix <== prefixFee;
    for(i = 0; i < nBytesFee; i++) {
        sm.in[i] <== pbot.out[i];
    }

    for(i = 0; i < nBytesFeeMarshal; i++) {
        out[i] <== sm.out[i];
    }
    length <== sm.length;
}

function getLengthFee(nAmount, nBytesFeeDenom, nBytesFeeAmount) {
    return nAmount * getLengthAmountMarshal() + getLengthGasLimitMarshal();
}

function getLengthFeeMarshal(nAmount, nBytesFeeDenom, nBytesFeeAmount) {
    return getLengthStringMarshal(getLengthFee(nAmount, nBytesFeeDenom, nBytesFeeAmount));
}



