// SPDX-License-Identifier: GPL-3.0
pragma circom 2.0.0;
include "../../../node_modules/circomlib/circuits/poseidon.circom";

// Computes MiMC([left, right])
template HashInner() {
    signal input L;
    signal input R;
    signal output out;

    component hasher = Poseidon(2);
    hasher.inputs[0] <== L;
    hasher.inputs[1] <== R;
    out <== hasher.out;
}

template Hash(nInputs) {
    signal input in[nInputs];
    signal output out;

    component hasher = Poseidon(nInputs);
    for(var i = 0; i < nInputs; i++) {
        hasher.inputs[i] <== in[i];
    }
    
    out <== hasher.out;
}