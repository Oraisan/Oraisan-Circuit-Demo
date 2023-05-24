// SPDX-License-Identifier: GPL-3.0
pragma circom 2.0.0;
include "../modeinfoencode.circom";

template ModeInfoEncodeVerifier() {
    var nBytesSingleMarshal  = getLengthSingleMarshal();
    var nBytesModeInfoMarshal = getLengthStringMarshal(nBytesSingleMarshal);

    signal input in;
    signal input out[nBytesModeInfoMarshal];

    var i;
    var j;
    component me = ModeInfoEncode();
    me.in <== in;

    for(i = 0; i < nBytesModeInfoMarshal; i++) {
        me.out[i] === out[i];
        log(i, me.out[i]);
    }
    log(me.length);
}


component main = ModeInfoEncodeVerifier();