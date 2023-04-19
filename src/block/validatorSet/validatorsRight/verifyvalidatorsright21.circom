// SPDX-License-Identifier: GPL-3.0
pragma circom 2.0.0;

include "../../../libs/validators/validatorhash.circom";
include "../../../libs/block/calculateblockhash.circom";
include "../../../libs/AVL_Tree/avlverifier.circom";
include "../../../libs/utils/convert.circom";
include "../../../libs/utils/address.circom";
include "../../../../node_modules/circomlib/circuits/bitify.circom";
include "../../../../node_modules/circomlib/circuits/switcher.circom";
include "../../../../node_modules/circomlib/circuits/comparators.circom";

template VerifyValidatorRight(nVals, nSiblings) {
    signal input pubkeys[nVals][32];
    signal input votingPowers[nVals];
    signal input childRoot[nSiblings][32];
    signal input validatorHash[32];
    signal input signed;
    
    signal output totalVPsigned;
    signal output totalVP;
    signal output validatorAddress[nVals];
    signal output validatorHashAddress;
    signal output dataHashAddress;
    signal output blockHashAddress;

    var i;
    var j;
    var vpsigned = 0;
    var vp = 0;

    //verifyDataHash
    component rcr = CalculateValidatorHash(nVals);

    for(i = 0; i < nVals; i++) {
        for(j = 0; j < 32; j++) {
            rcr.pubkeys[i][j] <== pubkeys[i][j];
        }
        rcr.votingPowers[i] <== votingPowers[i];
    }

    component r = CalculateRootFromSiblings(nSiblings);
    
    r.key <== 0;
    
    for(i = 0; i < nSiblings; i++) {
        for(j = 0; j < 32; j++) {
            r.siblings[i][j] <== childRoot[i][j];
        }
    }

    for(i = 0; i < 32; i++) {
        r.value[i] <== rcr.out[i];
    }

    for(i = 0; i < 32; i++) {
        validatorHash[i] === r.root[i];
    }

    // Verify blockHash
    component bh = CalculateBlockHashFromDataAndVals();
    for(i = 0; i < nVals; i++) {
        bh.dataHash[i] <== dataHash[i];
        bh.validatorsHash[i] <== validatorHash[i];

        for(j = 0; j < 3; j++) {
            bh.parrentSiblings[j][i] <== parrentSiblings[j][i];
        }
    }

    for(i = 0; i < nVals; i++) {
        blockHash[i] === bh.blockHash[i];
    }


    //Calculate VotingPower
    component checkSigned = Num2Bits(nVals);
    checkSigned.in <== signed;
    component sw[nVals];

    for(i = 0; i < nVals; i++) {
        sw[i] = Switcher();
        sw[i].sel <== checkSigned.out[i];
        sw[i].L <== 0;
        sw[i].R <== votingPowers[i];
        vp += votingPowers[i];
        vpsigned += sw[i].outL;
    }

    totalVPsigned <== vpsigned;
    totalVP <== vp;

    // ouput
    component addr[nVals];
    for(i = 0; i < nVals; i++) {
        addr[i] = CalculateValidatorAddress();
        for(j = 0; j < 32; j++) {
            addr[i].in[j] <== pubkeys[i][j];
        }
        validatorAddress[i] <== addr[i].out;
    }

    
    component validatorHashAddr = CalculateValidatorAddress();
    for(i = 0; i < 32; i++) {
        validatorHashAddr.in[i] <== validatorHash[i];
    }
    validatorHashAddress <== validatorHashAddr.out;

    component dataHashAddr = CalculateValidatorAddress();
    for(i = 0; i < 32; i++) {
        dataHashAddr.in[i] <== dataHash[i];
    }
    dataHashAddress <== dataHashAddr.out;

    component blockHashAddr = CalculateValidatorAddress();
    for(i = 0; i < 32; i++) {
        blockHashAddr.in[i] <== blockHash[i];
    }
    blockHashAddress <== blockHashAddr.out;
}
component main{public[signed]} = VerifyValidatorRight(21, 1);