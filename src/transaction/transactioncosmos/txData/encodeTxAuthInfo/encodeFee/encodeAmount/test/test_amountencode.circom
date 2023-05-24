// SPDX-License-Identifier: GPL-3.0
pragma circom 2.0.0;
include "../amountencode.circom";

template EncodeAmountArrayVeriier(nAmount) {
    var nBytesFeeDenom = getLengthFeeDenom();
    var nBytesFeeAmount = getLengthFeeAmount();
    var nBytesAmountMarshal = getLengthAmountMarshal();

    signal input authInfo_fee_amount_denom[nAmount][nBytesFeeDenom];
    signal input authInfo_fee_amount_amount[nAmount][nBytesFeeAmount];
    signal input out[nAmount * nBytesAmountMarshal];

    var i;
    var j;
    component aae = AmountArrayEncode(nAmount);
    for(i = 0; i < nAmount; i++) {
        for(j = 0; j < nBytesFeeDenom; j++) {
            aae.authInfo_fee_amount_denom[i][j] <== authInfo_fee_amount_denom[i][j];
        }

        for(j = 0; j < nBytesFeeAmount; j++) {
            aae.authInfo_fee_amount_amount[i][j] <== authInfo_fee_amount_amount[i][j];
        }
    }

    for(i = 0; i < nBytesAmountMarshal * nAmount; i++) {
        aae.out[i] === out[i];
        // log("i", aae.out[i]);
    }
    log(aae.length);
}


component main = EncodeAmountArrayVeriier(2);