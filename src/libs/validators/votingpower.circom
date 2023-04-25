// SPDX-License-Identifier: GPL-3.0
pragma circom 2.0.0;

include "../utils/convert.circom";

include "../../../node_modules/circomlib/circuits/bitify.circom";
include "../../../node_modules/circomlib/circuits/comparators.circom";
include "../../../node_modules/circomlib/circuits/switcher.circom";

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

template CheckVotingPower(nVals) {
    signal input votingPowers[nVals];
    signal input signed;
    signal output out;

    var i;
    var vpsigned = 0;
    var vp = 0;

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

    component rs = GreaterThan(252);
    rs.in[0] <== vpsigned * 3;
    rs.in[1] <== 2 * vp;

    out <== rs.out;
}

