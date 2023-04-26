// SPDX-License-Identifier: GPL-3.0
pragma circom 2.0.0;

include "./votingpower.circom";
include "../utils/convert.circom";
include "../utils/shiftbytes.circom";
include "../utils/filedsmsgheaderencode.circom";
include "../AVL_Tree/avlverifier.circom";
include "../sha/sha256prepared.circom";

include "../../../node_modules/circomlib/circuits/comparators.circom";

template ValidatorEncode(nVP) {
    var prefixValidator = 10;
    var prefixPubKey = 10;
    var prefixVotingPower = 16;
    var i;

    signal input pubkey[32];
    signal input votingPower;
    signal output out[37 + nVP];
    

    component vp = VotingPowerEncode(prefixVotingPower, nVP);
    vp.in <== votingPower;

    out[0] <== prefixValidator;

    // out[1] = lenPubkeyEncode = 32 (len pubkey) + 1 (byte len pubkey) + 1 (byte prefix)
    out[1] <== 34;
    out[2] <== prefixPubKey;
    out[3] <== 32;

    for(i = 0; i < 32; i++) {
        out[i + 4] <== pubkey[i];
    }

    for(i = 0; i < nVP + 1; i++) {
        out[i + 36] <== vp.out[i];
    }
}

template CheckEmptyValidator() {
    signal input pubkey[32];
    signal input votingPower;
    signal output out;

    var i;
    var check = 0;
    
    for(i = 0; i < 32; i++) {
        check += pubkey[i];
    }
    check += votingPower;

    component isEmpty= IsZero();
    isEmpty.in <== check;

    out <== isEmpty.out;
}

template ValidatorLeaf() {
    var nVP = 4;

    signal input pubkey[32];
    signal input votingPower;
    signal output out[32];
    
    signal cnt[1 + nVP];
    signal byteVPIndex[nVP];
    signal byteEndIndex[nVP];

    var i;
    var j;
    var byteEnd = 128;

    j = 1;

    for(i = 0; i < nVP - 1; i++) {
        j *= 128;
        byteVPIndex[i] <== j;
    }

    // encode validator (validatorHash, votingPower)
    component ve = ValidatorEncode(nVP);
    for(i = 0; i < 32; i++) {
        ve.pubkey[i] <== pubkey[i];
    }
    ve.votingPower <== votingPower;

    // process SovByte Voting Power
    component tsb = TrimSovBytes(nVP);
    for(i = 0; i < nVP; i++) {
        tsb.in[i] <== ve.out[37 + i];
    }

    //Calculate last byte before hash
    component lbe = LastBytesSHA256();
    lbe.in <== (38 + tsb.length) * 8;

    component vh = SHA256Message(38 + nVP);
    vh.in[0] <== 0;

    for(i = 0; i < 37; i++) {
        vh.in[i + 1] <== ve.out[i];
    }

    for(i = 0; i < nVP; i++) {
        vh.in[i + 38] <== tsb.out[i];
    }

    vh.length <== 38 + tsb.length;

    component isEmpty = CheckEmptyValidator();
    for(i = 0; i < 32; i++) {
        isEmpty.pubkey[i] <== pubkey[i];
    }
    isEmpty.votingPower <== votingPower;

    for(i = 0; i < 32; i++) {
        out[i] <== vh.out[i] * (1 - isEmpty.out);
    }
}

template CalculateValidatorHash(nValidators) {
    signal input pubkeys[nValidators][32];
    signal input votingPowers[nValidators];
    signal output out[32];

    var i;
    var j;

    component valLeafs[nValidators];

    for(i = 0; i < nValidators; i++) {
        valLeafs[i] = ValidatorLeaf();
        for(j = 0; j < 32; j++) {
            valLeafs[i].pubkey[j] <== pubkeys[i][j];
        }
        valLeafs[i].votingPower <== votingPowers[i];
    }

    component r = CalculateRootFromLeafs(nValidators);
    for(i = 0; i < nValidators; i++) {
        for(j = 0; j < 32; j++) {
            r.in[i][j] <==  valLeafs[i].out[j];
        }
        
    }

    for(i = 0; i < 32; i++) {
        out[i] <== r.out[i];
    }
}