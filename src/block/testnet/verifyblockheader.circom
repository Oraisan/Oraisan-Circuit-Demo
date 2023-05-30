// SPDX-License-Identifier: GPL-3.0
pragma circom 2.0.0;
include "../../libs/validators/signaturesverifier.circom";
include "../../libs/utils/address.circom";
include "../../libs/AVL_Tree/avlhash.circom";
include "../../libs/block/calculateblockhash.circom";
include "../../libs/validators/validatorhash.circom";
include "../../libs/validators/votingpower.circom";

template VerifyBlockHeader() {
    var nChainID = getNTestnetChainID();

    signal input height; 
    signal input dataHash[32];
    signal input parrentSiblings[3][32];
    signal input blockHash[32];

    signal input blockTime; 
    signal input partsTotal;
    signal input partsHash[32];
    signal input sigTimeSeconds;
    signal input sigTimeNanos;

    signal input pubKeys[32];
    signal input votingPowers;
    signal input R8[32];
    signal input S[32];

    signal input PointA[4][3];
    signal input PointR[4][3];


    signal output validatorAddress;
    signal output validatorHashAddress;
    signal output dataHashAddress;
    signal output blockhashAddress;

    var i;
    var j;
    var type = 2;
    // chainID = "Oraichain"
    var chainID[nChainID] = [79, 114, 97, 105, 99, 104, 97, 105, 110, 45, 116, 101, 115, 116, 110, 101, 116];

    component sv = SignatureVerifier(nChainID);
    sv.type <== type;

    for(i = 0; i < nChainID; i++) {
        sv.chainID[i] <== chainID[i];
    }

    sv.height <== height;
    
    for(i = 0; i < 32; i++) {
        sv.blockHash[i] <== blockHash[i];
    }

    sv.blockTime <== blockTime;
    sv.partsTotal <== partsTotal;

    for(i = 0; i < 32; i++) {
        sv.partsHash[i] <== partsHash[i];
    }
    

    sv.sigTimeSeconds <== sigTimeSeconds;
    sv.sigTimeNanos <== sigTimeNanos;

    for(i = 0; i < 32; i++) {
        sv.pubKeys[i] <== pubKeys[i];
        sv.R8[i] <== R8[i];
        sv.S[i] <== S[i];
    }

    for(i = 0; i < 4; i++) {
        for(j = 0; j < 3; j++) {
            sv.PointA[i][j] <== PointA[i][j];
            sv.PointR[i][j] <== PointR[i][j];
        }
    }

    //verifyDataHash
    component validatorHash = CalculateValidatorHash(1);

    for(j = 0; j < 32; j++) {
        validatorHash.pubkeys[0][j] <== pubKeys[j];
    }
    validatorHash.votingPowers[0] <== votingPowers;

    
    // Verify blockHash
    component bh = CalculateBlockHashFromDataAndVals();
    for(i = 0; i < 32; i++) {
        bh.dataHash[i] <== dataHash[i];
        bh.validatorsHash[i] <== validatorHash.out[i];

        for(j = 0; j < 3; j++) {
            bh.parrentSiblings[j][i] <== parrentSiblings[j][i];
        }
    }

    for(i = 0; i < 32; i++) {
        blockHash[i] === bh.blockHash[i];
    }

    component addr = CalculateAddress();
    for(i = 0; i < 32; i++) {
        addr.in[i] <== pubKeys[i];
    }

    validatorAddress <== addr.out;

    component validatorHashAddr = CalculateAddress();
    for(i = 0; i < 32; i++) {
        validatorHashAddr.in[i] <== validatorHash.out[i];
    }
    validatorHashAddress <== validatorHashAddr.out;

    component dataHashAddr = CalculateAddress();
    for(i = 0; i < 32; i++) {
        dataHashAddr.in[i] <== dataHash[i];
    }
    dataHashAddress <== dataHashAddr.out;

    component blockAddr = CalculateAddress();
    for(i = 0; i < 32; i++) {
        blockAddr.in[i] <== blockHash[i];
    }

    blockhashAddress <== blockAddr.out;

}

function getNTestnetChainID() {
    return 17;
}

component main = VerifyBlockHeader();