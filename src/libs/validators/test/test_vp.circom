// SPDX-License-Identifier: GPL-3.0
pragma circom 2.0.0;

include "../msgheaderencode.circom";
include "../validatorhash.circom";
include "../verify.circom";
include "../../AVL_Tree/avlhash.circom";
include "../../utils/address.circom";
include "../../utils/convert.circom";
include "../../../../electron-labs/verify.circom";
include "../../../../node_modules/circomlib/circuits/bitify.circom";
include "../../../../node_modules/@electron-labs/sha512/circuits/sha512/sha512.circom";

// template VerifyEncodeVP() {
//     signal input votingPower;

//     component vpe = VotingPowerEncode(16, 3);
//     vpe.in <== votingPower;

//     component lve = LastValidatorEncode(3);
//     lve.votingPower <== votingPower;
//     for(var i = 0; i < 3; i++) {
//         lve.in[i] <== vpe.out[i+1];
//     }

// }

template VerifyValidatorHash() {
    signal input pubkey[32];
    signal input votingPower;
    signal input validatorhash[32];

    var i;

    component vh = ValidatorLeaf();
    for(i = 0; i < 32; i++ ) {
        vh.pubkey[i] <== pubkey[i];
    }
    vh.votingPower <== votingPower;

    for(i = 0; i < 32; i++) {
        validatorhash[i] === vh.out[i];
    }
}

template VerifyRootVal(nVals) {
    signal input pubkeys[nVals][32];
    signal input votingPowers[nVals];
    signal input root[32];

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
        root[i] === r.out[i];
    }
}

template VerifyValidatorAddress() {
    signal input pubkeys[32];
    signal input address;

    component addr = CalculateAddress();
    for(var i = 0; i < 32; i++) {
        addr.pubkeys[i] <== pubkeys[i];
        
    }

    component ntb = Num2Bits(160);
    ntb.in <== address;
    address === addr.address;
}

template VerifyEncode() {
    signal input height;
    signal input blockHash[32];
    signal input partsTotal;
    signal input partsHash[32];
    signal input seconds;
    signal input nanos;
    signal input msg[111];
    var i;
    var j;
    var type = 2;
    // chainID = "Oraichain"
    var chainID[9] = [79, 114, 97, 105, 99, 104, 97, 105, 110];

    component me = MsgEncode(9);
    me.type <== 2;
    
    for(i = 0; i < 9; i++) {
        me.chainID[i] <== chainID[i];
    }

    me.height <== height;
    
    for(i = 0; i < 32; i ++) {
        me.blockHash[i] <== blockHash[i];
        me.partsHash[i] <== partsHash[i];
    }

    me.partsTotal <== partsTotal;
    me.seconds <== seconds;
    me.nanos <== nanos;

    log(me.length); 

    for(i = 0; i < 111; i++) {
        msg[i] === me.out[i];
    }

}

template VerifyHashMSG() {
    signal input msg[111];
    signal input pubKeys[32];
    signal input R8[32];

    var i;
    var j;

    component hmsg = HashValidatorMSG(111);

    for(i = 0; i < 111; i++) {
        hmsg.msg[i] <== msg[i];
    }
    hmsg.length <== 109;

    for(i = 0; i < 32; i++) {
        hmsg.A[i] <== pubKeys[i];
        hmsg.R8[i] <== R8[i];
    }

    component msg2Bits[111];
    for(i = 0; i < 111; i++) {
        msg2Bits[i] = BytesToBits(8);
        msg2Bits[i].in <== msg[i];
    }

    component pb2Bits[32];
    for(i = 0; i < 32; i++) {
        pb2Bits[i] = BytesToBits(8);
        pb2Bits[i].in <== pubKeys[i];
    }

    component r8ToBits[32];
    for(i = 0; i < 32; i++) {
        r8ToBits[i] = BytesToBits(8);
        r8ToBits[i].in <== R8[i];
    }

    component hash = Sha512(888  - 16 + 256 + 256);
    for (i=0; i<32; i+=1) {
        for(j=0; j<8; j++) {
            hash.in[i * 8 + j] <== r8ToBits[i].out[7-j];
            hash.in[ (32 + i) * 8 + j] <== pb2Bits[i].out[7-j];
        }
    }

    for (i=0; i<109; i+=1) {
        for(j=0; j<8; j++) {
        hash.in[512 + i * 8 + j] <== msg2Bits[i].out[7-j];
        }
    }

    component bitsToBytes[64];
    for (var i = 0; i < 64; i++) {
        bitsToBytes[i] = Bits2Num(8);
        for (var j = 0; j < 8; j++) {
            bitsToBytes[i].in[7-j] <== hash.out[i*8+j];
        }
        hmsg.out[i] === bitsToBytes[i].out;
    }
}

template VerifyAddRH() {
    signal input msg[111];
    signal input length;

    signal input pubKeys[32];
    signal input R8[32];
    
    signal input PointA[4][3];
    signal input PointR[4][3];

    var i;
    var j;

    // component rMsg[111];
    // for(i = 0; i < 111; i++){
    //     rMsg[i] = ReverseByte();
    //     rMsg[i].in <== msg[i];
    // }

    // component rPubKeys[32];
    // for(i = 0; i < 32; i++){
    //     rPubKeys[i] = ReverseByte();
    //     rPubKeys[i].in <== pubKeys[i];
    // }

    // component rR8[32];
    // for(i = 0; i < 32; i++){
    //     rR8[i] = ReverseByte();
    //     rR8[i].in <== R8[i];
    // }

    component cAddRH = CalculateAddRH(111);
    for(i = 0; i < 111; i++) {
        cAddRH.msg[i] <== msg[i];
    }
    cAddRH.length <== 111;
    
    for(i = 0; i < 32; i++) {
        cAddRH.A[i] <== pubKeys[i];
        cAddRH.R8[i] <== R8[i];
    }

    for(i = 0; i < 4; i++) {
        for(j = 0; j < 3; j++) {
            cAddRH.PointA[i][j] <== PointA[i][j];
            cAddRH.PointR[i][j] <== PointR[i][j];
        }
    }

    component msg2Bits[111];
    for(i = 0; i < 111; i++) {
        msg2Bits[i] = BytesToBits(8);
        msg2Bits[i].in <== msg[i];
    }

    component pb2Bits[32];
    for(i = 0; i < 32; i++) {
        pb2Bits[i] = BytesToBits(8);
        pb2Bits[i].in <== pubKeys[i];
    }

    component r8ToBits[32];
    for(i = 0; i < 32; i++) {
        r8ToBits[i] = BytesToBits(8);
        r8ToBits[i].in <== R8[i];
    }

    component cAddRH1 = CalculateAddRH1(888);
    for(i = 0; i < 111; i++) {
        for(j = 0; j < 8; j++) {
            cAddRH1.msg[i * 8 + j] <== msg2Bits[i].out[j];
        }
    }

    for(i = 0; i < 32; i++) {
        for(j = 0; j < 8; j++) {
            cAddRH1.A[i * 8 + j] <== pb2Bits[i].out[j];
            cAddRH1.R8[i * 8 + j] <== r8ToBits[i].out[j];
        }
    }

    for(i = 0; i < 4; i++) {
        for(j = 0; j < 3; j++) {
            cAddRH1.PointA[i][j] <== PointA[i][j];
            cAddRH1.PointR[i][j] <== PointR[i][j];
        }
    }

    for(i = 0; i < 4; i++) {
        for(j = 0; j < 3; j++) {
            cAddRH.R[i][j] === cAddRH1.R[i][j];
        }
    }
}
component main = VerifyAddRH();