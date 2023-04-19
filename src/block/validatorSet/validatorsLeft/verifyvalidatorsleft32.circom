// SPDX-License-Identifier: GPL-3.0
pragma circom 2.0.0;

include "../../../libs/validators/validatorhash.circom";
include "../../../libs/AVL_Tree/avlverifier.circom";
include "../../../libs/utils/convert.circom";
include "../../../libs/utils/address.circom";
include "../../../../node_modules/circomlib/circuits/bitify.circom";
include "../../../../node_modules/circomlib/circuits/switcher.circom";
include "../../../../node_modules/circomlib/circuits/comparators.circom";

template VerifyValidatorLeft(nVals, nSiblings) {
    signal input pubkeys[nVals][32];
    signal input votingPowers[nVals];
    signal input childRoot[nSiblings][32];
    
    signal input validatorHash[32];
    signal input dataHash[32];
    signal input parrentSiblings[3][32];
    signal input blockHash[32];

    signal input signed;
    
    signal output totalVPsigned;
    signal output totalVP;
    signal output validatorAddress[nVals];

    var i;
    var j;
    var vpsigned = 0;
    var vp = 0;

    //Calculate validatorHash
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

    component addr[nVals];
    for(i = 0; i < nVals; i++) {
        addr[i] = CalculateValidatorAddress();
        for(j = 0; j < 32; j++) {
            addr[i].in[j] <== pubkeys[i][j];
        }
        validatorAddress[i] <== addr[i].out;
    }
}
component main{public[signed]} = VerifyValidatorLeft(32, 1);