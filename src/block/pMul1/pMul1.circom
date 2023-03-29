// SPDX-License-Identifier: GPL-3.0
pragma circom 2.0.0;
include "../../libs/validators/validatorsverifier.circom";
include "../../../electron-labs/verify.circom";

template pMul1Verifier() {
    signal input S[255];
    signal input R[4][3];
    signal output sP[4][3];

    var i;
    var j;

    component pMul1 = CalculatePMul1();
    for(i = 0; i<255; i++) {
        pMul1.S[i] <== S[i];
    }

    component equal = PointEqual();
    for(i=0; i<3; i++) {
        for(j=0; j<3; j++) {
        equal.p[i][j] <== pMul1.sP[i][j];
        equal.q[i][j] <== R[i][j];
        }
    }

    log(equal.out);
    equal.out === 1;
}


component main{public[S, R]} = pMul1Verifier();