// SPDX-License-Identifier: GPL-3.0
pragma circom 2.0.0;
include "../../libs/validators/validatorsverifier.circom";
include "../../../electron-labs/verify.circom";

template AddRH() {
    // assert(n % 8 == 0);

    // signal input msg[n];

    signal input A[256];
    signal input R8[256];
    signal input hash[512];

    signal input PointA[4][3];
    signal input PointR[4][3];

    signal output R[4][3];

    var i;
    var j;


    component addRH = CalculateAddRH();

    // for( i = 0; i < n; i++) {
    //     addRH.msg[i] <== msg[i];
    // }

    for( i = 0; i < 512; i++) {
        addRH.hash[i] <== hash[i];
    }

    for(i = 0; i < 256; i++) {
        addRH.A[i] <== A[i];
        addRH.R8[i] <== R8[i];
    }

    for(i = 0; i < 4; i++) {
        for(j = 0; j < 3; j++) {
        addRH.PointA[i][j] <== PointA[i][j];
        addRH.PointR[i][j] <== PointR[i][j];
        }
    } 

    for ( i = 0; i < 4; i++) {
        for(j = 0; j < 3; j++) {
            R[i][j] <== addRH.R[i][j];
        }
    }
}


component main{public[A, R8, hash]} = AddRH();