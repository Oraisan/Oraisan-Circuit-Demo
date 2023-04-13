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