// SPDX-License-Identifier: GPL-3.0
pragma circom 2.0.0;

include "../sha/sha256standard.circom";
include "./convert.circom";

template CalculateAddress() {
    signal input in[32];
    signal output  out;

    var i;

    component pubkeyHash = Sha256Bytes(32);
    for(i = 0; i < 32; i++) {
        pubkeyHash.in[i] <== in[i];
    }

    component addr = BytesToNum(20);
    for(i = 0; i < 20; i++) {
        addr.in[i] <== pubkeyHash.out[i];
    }
    
    
    out <== addr.out;
}

template CalculateAddressBytes(nBytes) {
    signal input in[nBytes];
    signal output  out;

    var i;

    component pubkeyHash = Sha256Bytes(nBytes);
    for(i = 0; i < nBytes; i++) {
        pubkeyHash.in[i] <== in[i];
    }

    component addr = BytesToNum(20);
    for(i = 0; i < 20; i++) {
        addr.in[i] <== pubkeyHash.out[i];
    }
    
    
    out <== addr.out;
}