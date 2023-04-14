// SPDX-License-Identifier: GPL-3.0
pragma circom 2.0.0;
include "../../../node_modules/circomlib/circuits/mimc.circom";

// Computes MiMC([left, right])
template HashInner() {
    signal input L;
    signal input R;
    signal output out;

    component hasher = MultiMiMC7(2, 91);
    hasher.in[0] <== L;
    hasher.in[1] <== R;
    hasher.k <== 0;
    out <== hasher.out;
}

template Hash(nInputs) {
    signal input in[nInputs];
    signal output out;

    component hasher = MultiMiMC7(nInputs, 91);
    for(var i = 0; i < nInputs; i++) {
        hasher.in[i] <== in[i];
    }
    hasher.k <== 0;
    
    out <== hasher.out;
}