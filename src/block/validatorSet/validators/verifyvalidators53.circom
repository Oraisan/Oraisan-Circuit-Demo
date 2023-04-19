// SPDX-License-Identifier: GPL-3.0
pragma circom 2.0.0;

include "../../../libs/validators/validatorhash.circom";
include "../../../libs/validators/votingpower.circom";
include "../../../libs/block/calculateblockhash.circom";
include "../../../libs/AVL_Tree/avlhash.circom";

template VerifyValidatorsHash(nVals) {
    var prefixBytes = 10;

    signal input pubkeys[nVals][32];
    signal input votingPowers[nVals];
    
    signal input validatorHash[32];
    signal input dataHash[32];
    signal input parrentSiblings[3][32];
    signal input blockHash[32];

    signal input signed[nVals];

    var i;
    var j;
    var vpsigned = 0;
    var vp = 0;

    component vh = CalculateValidatorHash(nVals);
    component sw[nVals];

    for(i = 0; i < nVals; i++) {
        for(j = 0; j < 32; j++) {
            vh.pubkeys[i][j] <== pubkeys[i][j];
        }
        vh.votingPowers[i] <== votingPowers[i];
    }

    for(i = 0; i < 32; i++) {
        validatorHash[i] === vh.out[i];
    }

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

    component 
    component cvp = CheckVotingPower(nVals);

    for(i = 0; i < nVals; i++) {
        cvp.votingPower[i] <== votingPower[i];
        cvp.signed[i] <== signed[i];
    }

    cvp.out === 1;
}
component main{public[signed, dataHash, validatorHash, blockHash, pubkeys]} = VerifyValidatorsHash(53);