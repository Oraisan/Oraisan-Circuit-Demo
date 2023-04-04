// SPDX-License-Identifier: GPL-3.0
pragma circom 2.0.0;
include "../../libs/validators/signaturesverifier.circom";

// template BlockVerifierByBits(nBits) {
//     signal input msg[nBits];
    
//     signal input pubKeys[256];
//     signal input R8[256];
//     signal input S[255];

//     signal input PointA[4][3];
//     signal input PointR[4][3];

//     var i;
//     var j;
//     component v = SignatureVerifier(nBits);
    
//     for(i = 0; i < nBits; i++) {
//         v.msg[i] <== msg[i];
//     }

//     for(i = 0; i < 256; i++) {
//         v.pubKeys[i] <== pubKeys[i];
//         v.R8[i] <== R8[i];
//     }

//     for(i = 0; i < 255; i++) {
//         v.S[i] <== S[i];
//     }

//     for(i = 0; i < 4; i++) {
//         for(j = 0; j < 3; j++) {
//             v.PointA[i][j] <== PointA[i][j];
//             v.PointR[i][j] <== PointR[i][j];
//         }
//     }
// }

// template BlockVerifierByBytes(nBytes) {
//     signal input msg[nBytes];
    
//     signal input pubKeys[32];
//     signal input R8[32];
//     signal input S[32];

//     signal input PointA[4][3];
//     signal input PointR[4][3];

//     var i;
//     var j;
//     component v = SignatureVerifierByBytes(nBytes);
    
//     for(i = 0; i < nBytes; i++) {
//         v.msg[i] <== msg[i];
//     }

//     for(i = 0; i < 32; i++) {
//         v.pubKeys[i] <== pubKeys[i];
//         v.R8[i] <== R8[i];
//     }

//     for(i = 0; i < 32; i++) {
//         v.S[i] <== S[i];
//     }

//     for(i = 0; i < 4; i++) {
//         for(j = 0; j < 3; j++) {
//             v.PointA[i][j] <== PointA[i][j];
//             v.PointR[i][j] <== PointR[i][j];
//         }
//     }
// }


component main{public[pubKeys]} = SignatureVerifier(888);