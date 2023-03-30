// SPDX-License-Identifier: GPL-3.0
pragma circom 2.0.0;
include "../../libs/validators/validatorsverifier.circom";
include "../../../electron-labs/verify.circom";

template AddRH(n) {
  assert(n % 8 == 0);

  signal input msg[n];

  signal input A[256];
  signal input R8[256];
  
  signal input PointA[4][3];
  signal input PointR[4][3];

  signal output R[4][3];

  var i;
  var j;

  component compressA = PointCompress();
  component compressR = PointCompress();
  for (i=0; i<4; i++) {
    for (j=0; j<3; j++) {
      compressA.P[i][j] <== PointA[i][j];
      compressR.P[i][j] <== PointR[i][j];
    }
  }

  for (i=0; i<256; i++) {
    compressA.out[i] === A[i];
    compressR.out[i] === R8[i];
  }

  component hash = Sha512(n+256+256);
  for (i=0; i<256; i+=8) {
    for(j=0; j<8; j++) {
      hash.in[i+j] <== R8[i+(7-j)];
      hash.in[256+i+j] <== A[i+(7-j)];
    }
  }

  for (i=0; i<n; i+=8) {
    for(j=0; j<8; j++) {
      hash.in[512+i+j] <== msg[i+(7-j)];
    }
  }

  component bitModulus = ModulusWith252c(512);
  for (i=0; i<512; i+=8) {
    for(j=0; j<8; j++) {
      bitModulus.in[i+j] <== hash.out[i + (7-j)];
    }
  }

  component pMul2 = ScalarMul();
  for (i=0; i<253; i++) {
    pMul2.s[i] <== bitModulus.out[i];
  }
  pMul2.s[253] <== 0;
  pMul2.s[254] <== 0;

  for (i=0; i<4; i++) {
    for (j=0; j<3; j++) {
      pMul2.P[i][j] <== PointA[i][j];
    }
  }

  component addRH = PointAdd();
  for (i=0; i<4; i++) {
    for (j=0; j<3; j++) {
      addRH.P[i][j] <== PointR[i][j];
      addRH.Q[i][j] <== pMul2.sP[i][j];
    }
  }

  for ( i = 0; i < 4; i++) {
    for(j = 0; j < 3; j++) {
      R[i][j] <== addRH.R[i][j];
    }
  }
}


component main{public[msg]} = AddRH(888);