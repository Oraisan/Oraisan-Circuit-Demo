// SPDX-License-Identifier: GPL-3.0
pragma circom 2.0.0;

include "../../../libs/validators/validatorhash.circom";
include "../../../libs/AVL_Tree/avlhash.circom";
include "../../../../node_modules/circomlib/circuits/switcher.circom";

template VerifyValidatorsRight(nVals) {
    signal input pubkeys[nVals][32];
    signal input votingPowers[nVals];
    signal input leftChildRoot[32];
    signal input validatorHash[32];
    signal input signed[nVals];
    signal output totalVPsigned;
    signal output totalVP;

    var i;
    var j;
    var vpsigned = 0;
    var vp = 0;

    component lcr = CalculateValidatorHash(nVals);
    component sw[nVals];

    for(i = 0; i < nVals; i++) {
        for(j = 0; j < 32; j++) {
            lcr.pubkeys[i][j] <== pubkeys[i][j];
        }
        lcr.votingPowers[i] <== votingPowers[i];

        sw[i] = Switcher();
        sw[i].sel <== signed[i];
        sw[i].L <== 0;
        sw[i].R <== votingPowers[i];
        vp += votingPowers[i];
        vpsigned += sw[i].outL;
    }

    component r = HashInner(32);
    for(i = 0; i < 32; i++) {
        r.L[i] <== leftChildRoot[i];
        r.R[i] <== lcr.out[i];
    }

    for(i = 0; i < 32; i++) {
        validatorHash[i] === r.out[i];
    }
    
    totalVPsigned <== vpsigned;
    totalVP <== vp;
}
component main{public[signed, validatorHash, pubkeys]} = VerifyValidatorsRight(21);