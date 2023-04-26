pragma circom 2.0.0;

include "./../../../electron-labs/scalarmul.circom";
include "./../../../electron-labs/modulus.circom";
include "./../../../electron-labs/point-addition.circom";
include "./../../../electron-labs/pointcompress.circom";

include "./../../../node_modules/@electron-labs/sha512/circuits/sha512/sha512.circom";
include "./../../../node_modules/circomlib/circuits/comparators.circom";
include "./../../../node_modules/circomlib/circuits/gates.circom";

include "../sha/sha512prepared.circom";
include "../utils/convert.circom";
include "../utils/shiftbytes.circom";

template Ed25519Verifier(nBytes) {
  
  signal input msg[nBytes];
  signal input length;
  
  signal input A[32];
  signal input R8[32];
  signal input S[32];

  signal input PointA[4][3];
  signal input PointR[4][3];

  signal output out;

  var i;
  var j;

  component pMul1 = CalculatePMul1();
  for(i = 0; i < 32; i++) {
    pMul1.S[i] <== S[i];
  }

  component addRH = CalculateAddRH(nBytes);
  for(i = 0; i < nBytes; i++) {
    addRH.msg[i] <== msg[i];
  }
  addRH.length <== length;

  for(i = 0; i < 32; i++) {
    addRH.A[i] <== A[i];
    addRH.R8[i] <== R8[i];
  }

  for(i = 0; i < 4; i++) {
    for(j = 0; j < 3; j++) {
      addRH.PointA[i][j] <== PointA[i][j];
      addRH.PointR[i][j] <== PointR[i][j];
    }
  }

  component equal = PointEqual();
  for(i=0; i<3; i++) {
    for(j=0; j<3; j++) {
      equal.p[i][j] <== pMul1.sP[i][j];
      equal.q[i][j] <== addRH.R[i][j];
    }
  }

  out <== equal.out;
}

template CalculatePMul1() {
    signal input S[32];
    signal output sP[4][3];

    var G[4][3] = [[6836562328990639286768922, 21231440843933962135602345, 10097852978535018773096760],
                    [7737125245533626718119512, 23211375736600880154358579, 30948500982134506872478105],
                    [1, 0, 0],
                    [20943500354259764865654179, 24722277920680796426601402, 31289658119428895172835987]
                    ];

    var i;
    var j;

    component S2Bits[32];
    for(i = 0; i < 32; i++) {
        S2Bits[i] = BytesToBits(8);
        S2Bits[i].in <== S[i];
    }

    component pMul1 = ScalarMul();
    for(i = 0; i < 31; i++) {
        for(j = 0; j < 8; j++) {
            pMul1.s[i * 8 + j] <== S2Bits[i].out[j];
        }
    }

    for(i = 0; i < 7; i++) {
        pMul1.s[248 + i] <== S2Bits[31].out[i];
    }

    // point multiplication s, G
    //   for(i=0; i<255; i++) {
    //     pMul1.s[i] <== S[i];
    //   }
    for (i=0; i<4; i++) {
        for (j=0; j<3; j++) {
            pMul1.P[i][j] <== G[i][j];
        }
    }

    for (i = 0; i < 4; i++ ) {
        for(j = 0; j < 3; j++) {
            sP[i][j] <== pMul1.sP[i][j];
        }
    }
}

template CalculateAddRH(nBytes) {

    signal input msg[nBytes];
    signal input length;

    signal input A[32];
    signal input R8[32];
    
    signal input PointA[4][3];
    signal input PointR[4][3];

    signal output R[4][3];

    var i;
    var j;

    component A2Bits[32];
    for(i = 0; i < 32; i++) {
        A2Bits[i] = BytesToBits(8);
        A2Bits[i].in <== A[i];
    }

    component R8ToBits[32];
    for(i = 0; i < 32; i++) {
        R8ToBits[i] = BytesToBits(8);
        R8ToBits[i].in <== R8[i];
    }
    
    component compressA = PointCompress();
    component compressR = PointCompress();
    for (i=0; i<4; i++) {
        for (j=0; j<3; j++) {
        compressA.P[i][j] <== PointA[i][j];
        compressR.P[i][j] <== PointR[i][j];
        }
    }

    for (i=0; i<32; i++) {
        for(j = 0; j < 8; j++) {
            compressA.out[i * 8 + j] === A2Bits[i].out[j];
            compressR.out[i * 8 + j] === R8ToBits[i].out[j];
        }
    }
    
    component hash = SHA512Message(nBytes + 64);

    for(i = 0; i < 32; i++) {
        hash.in[i] <== R8[i];
        hash.in[i + 32] <== A[i];
    }

    for(i = 0; i < nBytes; i++) {
        hash.in[i + 64] <== msg[i];
    }
    
    hash.length <== length + 64;

    component hashBits[64];
    for(i = 0; i < 64; i++) {
        hashBits[i] = BytesToBits(8);
        hashBits[i].in <== hash.out[i];
        
    }

    component bitModulus = ModulusWith252c(512);
    for (i=0; i<64; i+=1) {
        for(j=0; j<8; j++) {
        bitModulus.in[i * 8 + j] <== hashBits[i].out[j];
        }
        // log("new hash", i, hashBits[i].out[7], hashBits[i].out[6], hashBits[i].out[5], hashBits[i].out[4], hashBits[i].out[3], hashBits[i].out[2], hashBits[i].out[1], hashBits[i].out[0]);
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

template PointEqual() {
    signal input p[3][3];
    signal input q[3][3];
    signal output out;

    var i;
    var j;
    component mul[4];
    for (i=0; i<4; i++) {
        mul[i] = ChunkedMul(3, 3, 85);
    }
    
    for(i=0; i<3; i++) {
        // P[0] * Q[2]
        mul[0].in1[i] <== p[0][i];
        mul[0].in2[i] <== q[2][i];

        // Q[0] * P[2]
        mul[1].in1[i] <== q[0][i];
        mul[1].in2[i] <== p[2][i];

        // P[1] * Q[2]
        mul[2].in1[i] <== p[1][i];
        mul[2].in2[i] <== q[2][i];

        // Q[1] * P[2]
        mul[3].in1[i] <== q[1][i];
        mul[3].in2[i] <== p[2][i];
    }

    component mod[4];
    for (i=0; i<4; i++) {
        mod[i] = ModulusWith25519Chunked51(6);
    }
    
    for(i=0; i<6; i++) {
        // (P[0] * Q[2]) % p
        mod[0].in[i] <== mul[0].out[i];

        // (Q[0] * P[2]) % p
        mod[1].in[i] <== mul[1].out[i];

        // (P[1] * Q[2]) % p
        mod[2].in[i] <== mul[2].out[i];

        // (Q[1] * P[2]) % p
        mod[3].in[i] <== mul[3].out[i];
    }

    // output = (P[0] * Q[2]) % p == (Q[0] * P[2]) % p && (P[1] * Q[2]) % p == (Q[1] * P[2]) % p

    component equal[2][3];
    component and1[3];
    component and2[2];

    for (j = 0; j < 2; j++) {
        equal[j][0] = IsEqual();
        equal[j][0].in[0] <== mod[2 * j].out[0];
        equal[j][0].in[1] <== mod[2 * j + 1].out[0];
    }

    and1[0] = AND();
    and1[0].a <== equal[0][0].out;
    and1[0].b <== equal[1][0].out;

    for (i=1; i<3; i++) {
        for (j = 0; j < 2; j++) {
        equal[j][i] = IsEqual();
        equal[j][i].in[0] <== mod[2 * j].out[i];
        equal[j][i].in[1] <== mod[2 * j + 1].out[i];
        }

        and1[i] = AND();
        and1[i].a <== equal[0][i].out;
        and1[i].b <== equal[1][i].out;

        and2[i-1] = AND();
        and2[i-1].a <== and1[i-1].out;
        and2[i-1].b <== and1[i].out;
    }

    out <== and2[1].out;
}

template HashValidatorMSG(nBytes) {
    signal input msg[nBytes];
    signal input length;

    signal input A[32];
    signal input R8[32];
    
    signal output out[64];

    var i;

    component hmsg = SHA512Message(nBytes + 64);
    for(i = 0; i < 32; i++) {
        hmsg.in[i] <== R8[i];
        hmsg.in[i + 32] <== A[i];
    }

    for(i = 0; i < nBytes; i++) {
        hmsg.in[i + 64] <== msg[i];
    }
    
    hmsg.length <== length + 64;

    for(i = 0; i < 64; i++) {
        out[i] <== hmsg.out[i];
    }
    // var j;
    // var lenHash = 512 + length * 8;

    // component pbot = PutBytesOnTop(nBytes, 1);
    
    // for(i = 0; i < nBytes; i++) {
    //     pbot.s1[i] <== msg[i];
    // }
    // pbot.s2[0] <== 128;
    // pbot.idx <== length;

    // component lb =  LastBytesSHA512();
    // lb.in <== lenHash;

    // component hp = Sha512Prepared(2);
    // for(i = 0; i < 32; i++) {
    //     hp.in[i] <== R8[i];
    //     hp.in[i + 32] <== A[i];
    // }

    // for(i = 0; i < nBytes + 1; i++) {
    //     hp.in[i + 64] <== pbot.out[i];
    // }

    // for(i = 65 + nBytes; i < 240; i++) {
    //     hp.in[i] <== 0;
    // }

    // for(i = 0; i < 16; i++) {
    //     hp.in[i + 240] <== lb.out[i];
    // }

    // for(i = 0; i < 64; i++) {
    //     out[i] <== hp.out[i];
    // }
}