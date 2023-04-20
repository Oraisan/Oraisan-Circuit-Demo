// SPDX-License-Identifier: GPL-3.0
pragma circom 2.0.0;

include "../validatorhash.circom";
include "../validatoraddress.circom";
include "../../../../node_modules/circomlib/circuits/bitify.circom";
include "../../AVL_Tree/avlhash.circom";

template VerifyEncode() {
    signal input votingPower;

    component vpe = VotingPowerEncode(16, 3);
    vpe.in <== votingPower;

    component lve = LastValidatorEncode(3);
    lve.votingPower <== votingPower;
    for(var i = 0; i < 3; i++) {
        lve.in[i] <== vpe.out[i+1];
    }

}

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
component main{public[address]} = VerifyValidatorAddress();