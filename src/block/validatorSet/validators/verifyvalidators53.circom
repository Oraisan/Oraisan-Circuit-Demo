// SPDX-License-Identifier: GPL-3.0
pragma circom 2.0.0;

include "../../../libs/AVL_Tree/avlhash.circom";
include "../../../libs/block/calculateblockhash.circom";
include "../../../libs/validators/validatorhash.circom";
include "../../../libs/validators/votingpower.circom";
include "../../../libs/utils/address.circom";

template VerifyValidatorsHash(nVals) {
    signal input pubkeys[nVals][32];
    signal input votingPowers[nVals];

    signal input validatorHash[32];
    signal input dataHash[32];
    signal input parrentSiblings[3][32];
    signal input blockHash[32];
    
    signal input signed;
    
    signal output totalVPsigned;
    signal output totalVP;
    signal output validatorAddress[nVals];
    signal output validatorHashAddress;
    signal output dataHashAddress;
    signal output blockHashAddress;

    var i;
    var j;

    //verifyDataHash
    component r = CalculateValidatorHash(nVals);

    for(i = 0; i < nVals; i++) {
        for(j = 0; j < 32; j++) {
            r.pubkeys[i][j] <== pubkeys[i][j];
        }
        r.votingPowers[i] <== votingPowers[i];
    }

    for(i = 0; i < 32; i++) {
        validatorHash[i] === r.out[i];
    }

    // Verify blockHash
    component bh = CalculateBlockHashFromDataAndVals();
    for(i = 0; i < 32; i++) {
        bh.dataHash[i] <== dataHash[i];
        bh.validatorsHash[i] <== validatorHash[i];

        for(j = 0; j < 3; j++) {
            bh.parrentSiblings[j][i] <== parrentSiblings[j][i];
        }
    }

    for(i = 0; i < 32; i++) {
        blockHash[i] === bh.blockHash[i];
    }


    // verify voting power
    component cvp = CheckVotingPower(nVals);

    cvp.signed <== signed;
    for(i = 0; i < nVals; i++) {
        cvp.votingPowers[i] <== votingPowers[i];
    }

    cvp.out === 1;

    // ouput
    component addr[nVals];
    for(i = 0; i < nVals; i++) {
        addr[i] = CalculateAddress();
        for(j = 0; j < 32; j++) {
            addr[i].in[j] <== pubkeys[i][j];
        }
        validatorAddress[i] <== addr[i].out;
    }

    
    component validatorHashAddr = CalculateAddress();
    for(i = 0; i < 32; i++) {
        validatorHashAddr.in[i] <== validatorHash[i];
    }
    validatorHashAddress <== validatorHashAddr.out;

    component dataHashAddr = CalculateAddress();
    for(i = 0; i < 32; i++) {
        dataHashAddr.in[i] <== dataHash[i];
    }
    dataHashAddress <== dataHashAddr.out;

    component blockHashAddr = CalculateAddress();
    for(i = 0; i < 32; i++) {
        blockHashAddr.in[i] <== blockHash[i];
    }
    blockHashAddress <== blockHashAddr.out;
}
component main{public[signed]} = VerifyValidatorsHash(53);