// SPDX-License-Identifier: GPL-3.0
pragma circom 2.0.0;
include "../gaslimitencode.circom";

template GasLimitEncodeVerifier() {
    var nBytes = getLengthGasLimit();
    signal input authInfo_fee_gasLimit;
    signal input out[1 + nBytes];
    component ge = GasLimitEncode();
    ge.authInfo_fee_gasLimit <== authInfo_fee_gasLimit;
    for(var i = 0; i < 1 + nBytes; i++) {
        ge.out[i] === out[i];
    }
    log(ge.length);
}

component main = GasLimitEncodeVerifier();