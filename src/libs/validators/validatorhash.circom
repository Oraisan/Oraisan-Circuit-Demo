// SPDX-License-Identifier: GPL-3.0
pragma circom 2.0.0;

include "../utils/convert.circom";
include "../utils/filedsmsgheaderencode.circom";
include "../sha256/sha256prepared.circom";
include "../AVL_Tree/avlverifier.circom";

include "../../../node_modules/circomlib/circuits/comparators.circom";


template LastValidatorEncode(nVP) {
    signal input votingPower;
    signal input in[nVP];

    signal output out[nVP + 1];
    signal output lastBytes[8];

    signal byteEndIndex[nVP + 1];

    var i;
    var j;
    var len = 39;
    var byteEnd = 128;
    var byteVPIndex[nVP];

    j = 1;

    for(i = 0; i < nVP; i++) {
        j *= 128;
        byteVPIndex[i] = j;
    }

    component idxVP[nVP];
    component sw[nVP];

    byteEndIndex[0] <== 0;
    for(i = 0; i < nVP; i++) {
        idxVP[i] = GreaterEqThan(nVP * 8);
        idxVP[i].in[0] <== votingPower;
        idxVP[i].in[1] <== byteVPIndex[i];
    
        byteEndIndex[i + 1] <== i == 0 ? (1 - idxVP[i].out) : (1 - idxVP[i].out) * idxVP[i - 1].out;
        
        sw[i] = SwitchSovByte();
        sw[i].xor <== idxVP[i].out;
        sw[i].in <== in[i];

        out[i] <== sw[i].out * (1 - byteEndIndex[i]) + byteEndIndex[i] * byteEnd;
        len += idxVP[i].out;
    }
    out[nVP] <== byteEndIndex[nVP] * byteEnd;

    component lbe = LastBytesSHA256();
    lbe.in <== len * 8;

    for( i = 0; i < 8; i++) {
        lastBytes[i] <== lbe.out[i];
    }
}

template VotingPowerEncode(prefixVotingPower, n) {
    signal input in;
    signal output out[n + 1];

    component sntb = SovNumToBytes(n);
    sntb.in <== in;
    
    out[0] <== prefixVotingPower;
    for(var i = 0; i < n; i++) {
        out[i + 1] <== sntb.out[i];
    }
}

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
    // 2^7; 2^14; 2^21
    
    j = 1;

    for(i = 0; i < nVP - 1; i++) {
        j *= 128;
        byteVPIndex[i] <== j;
    }

    component ve = ValidatorEncode(nVP);
    for(i = 0; i < 32; i++) {
        ve.pubkey[i] <== pubkey[i];
    }
    ve.votingPower <== votingPower;

    component lve = LastValidatorEncode(nVP);
    lve.votingPower <== votingPower;
    for(i = 0; i < nVP; i++) {
        lve.in[i] <== ve.out[37 + i];
    }

    component vh = Sha256Prepared(1);
    vh.in[0] <== 0;

    for(i = 0; i < 37; i++) {
        vh.in[i + 1] <== ve.out[i];
    }

    for(i = 0; i < nVP + 1; i++) {
        vh.in[i + 38] <== lve.out[i];
    }

    for(i = 39 + nVP; i < 56; i++) {
        vh.in[i] <== 0;
    }

    for(i = 0; i < 8; i++) {
        vh.in[56 + i] <== lve.lastBytes[i];
    }

    for(i = 0; i < 32; i++) {
        out[i] <== vh.out[i];
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