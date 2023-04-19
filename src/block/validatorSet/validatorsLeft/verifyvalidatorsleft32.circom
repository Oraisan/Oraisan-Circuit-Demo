// SPDX-License-Identifier: GPL-3.0
pragma circom 2.0.0;

include "../../../libs/validators/validatorhash.circom";
include "../../../libs/AVL_Tree/avlhash.circom";
include "../../../libs/utils/convert.circom";
include "../../../../node_modules/circomlib/circuits/switcher.circom";
include "../../../../node_modules/circomlib/circuits/comparators.circom";

template VerifyValidatorLeft(nVals) {
    signal input pubkeys[nVals][2];
    signal input votingPowers[nVals];
    signal input rightChildRoot[2];
    signal input validatorHash[2];
    signal input signed[nVals];
    signal output totalVPsigned;
    signal output totalVP;
    var i;
    var j;
    var vpsigned = 0;
    var vp = 0;

    component checkSigned[nVals];
    for(i = 0; i < nVals; i++) {
        checkSigned[i] = LessThan(16);
        checkSigned[i].in[0] <== signed[i];
        checkSigned[i].in[1] <== nVals;
    }

    component pubkeysToBytes[nVals][2];
    component rightChildRootToBytes[2];
    component validatorHashToBytes[2];

    for(i = 0; i < nVals; i++) {
        for(j = 0; j < 2; j++) {
            pubkeysToBytes[i][j] = NumToBytes(16);
            pubkeysToBytes[i][j].in <== pubkeys[i][j];
        }
    }

    for(i = 0; i < 2; i++) {
        rightChildRootToBytes[i] = NumToBytes(16);
        rightChildRootToBytes[i].in <== rightChildRoot[i];

        validatorHashToBytes[i] = NumToBytes(16);
        validatorHashToBytes[i].in <== validatorHash[i];
    }

    component rcr = CalculateValidatorHash(nVals);
    component sw[nVals];

    for(i = 0; i < nVals; i++) {
        for(j = 0; j < 16; j++) {
            rcr.pubkeys[i][j] <== pubkeysToBytes[i][0].out[j];
            rcr.pubkeys[i][j + 16] <== pubkeysToBytes[i][1].out[j];
        }
        rcr.votingPowers[i] <== votingPowers[i];

        sw[i] = Switcher();
        sw[i].sel <== checkSigned[i].out;
        sw[i].L <== 0;
        sw[i].R <== votingPowers[i];
        vp += votingPowers[i];
        vpsigned += sw[i].outL;
    }

    component r = HashInner(32);
    for(i = 0; i < 16; i++) {
        r.L[i] <== rcr.out[i];
        r.L[i + 16] <== rcr.out[i + 16];

        r.R[i] <== rightChildRootToBytes[0].out[i];
        r.R[i + 16] <== rightChildRootToBytes[1].out[i];
    }

    for(i = 0; i < 16; i++) {
        validatorHashToBytes[0].out[i] === r.out[i];
        validatorHashToBytes[1].out[i] === r.out[i + 16];
    }
    
    totalVPsigned <== vpsigned;
    totalVP <== vp;
}
component main{public[signed, validatorHash, pubkeys]} = VerifyValidatorLeft(32);