// SPDX-License-Identifier: GPL-3.0
pragma circom 2.0.0;

include "../../libs/validators/validatorhash.circom";

template VerifyValidatorSet(nVals) {
    signal input pubkeys[nVals][32];
    signal input votingPowers[nVals];
    signal input blockHash[32];

    var i;
    var j;

    component r = CalculateValidatorHash(nVals);

    for(i = 0; i < nVals; i++) {
        for(j = 0; j < 32; j++) {
            r.pubkeys[i][j] <== pubkeys[i][j];
        }
        r.votingPowers[i] <== votingPowers[i];
    }

    for(i = 0; i < 32; i++) {
        blockHash[i] === r.out[i];
    }
}
component main = VerifyValidatorSet(32);