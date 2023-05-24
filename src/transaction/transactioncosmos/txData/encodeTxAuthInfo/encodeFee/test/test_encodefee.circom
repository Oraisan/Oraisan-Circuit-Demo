// SPDX-License-Identifier: GPL-3.0
pragma circom 2.0.0;
include "../feeencode.circom";

template EncodeFeeVeriier(nAmount) {
    var nBytesFeeDenom = getLengthFeeDenom();
    var nBytesFeeAmount = getLengthFeeAmount();
    var nBytesAmountMarshal = getLengthAmountMarshal();
    var nBytesGasLimitMarshal = getLengthGasLimitMarshal();

    var nBytesFee = nBytesAmountMarshal * nAmount + nBytesGasLimitMarshal;
    var nBytesFeeMarshal = getLengthStringMarshal(nBytesFee);

    signal input authInfo_fee_amount_denom[nAmount][nBytesFeeDenom];
    signal input authInfo_fee_amount_amount[nAmount][nBytesFeeAmount];
    signal input authInfo_fee_gasLimit;
    signal input out[nBytesFeeMarshal];

    var i;
    var j;
    component fe = FeeEncode(nAmount);
    for(i = 0; i < nAmount; i++) {
        for(j = 0; j < nBytesFeeDenom; j++) {
            fe.authInfo_fee_amount_denom[i][j] <== authInfo_fee_amount_denom[i][j];
        }

        for(j = 0; j < nBytesFeeAmount; j++) {
            fe.authInfo_fee_amount_amount[i][j] <== authInfo_fee_amount_amount[i][j];
        }
    }
    fe.authInfo_fee_gasLimit <== authInfo_fee_gasLimit;

    for(i = 0; i < nBytesAmountMarshal * nAmount; i++) {
        fe.out[i] === out[i];
        // log("i", fe.out[i]);
    }
    log(fe.length);
}

// template EncodeAmountVeriier(nBytesFeeDenom, nBytesFeeAmount) {
//     var nBytesAmountMarshal = getLengthAmountMarshal(nBytesFeeDenom, nBytesFeeAmount);

//     signal input authInfo_fee_amount_denom[nBytesFeeDenom];
//     signal input authInfo_fee_amount_amount[nBytesFeeAmount];
//     signal input out[nBytesAmountMarshal];

//     var i;
//     var j;
//     component aae = AmountEncode(nBytesFeeDenom, nBytesFeeAmount);
//     for(j = 0; j < nBytesFeeDenom; j++) {
//         aae.authInfo_fee_amount_denom[j] <== authInfo_fee_amount_denom[j];
//     }

//     for(j = 0; j < nBytesFeeAmount; j++) {
//         aae.authInfo_fee_amount_amount[j] <== authInfo_fee_amount_amount[j];
//     }
    

//     for(i = 0; i < nBytesAmountMarshal; i++) {
//         aae.out[i] === out[i];
//     }
//     log(aae.length);
// }

component main = EncodeFeeVeriier(1);