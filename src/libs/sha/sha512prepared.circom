pragma circom 2.0.0;

include "../../../node_modules/@electron-labs/sha512/circuits/sha512/constants.circom";
include "../../../node_modules/@electron-labs/sha512/circuits/sha512/sha512compression.circom";
include "../../../node_modules/circomlib/circuits/bitify.circom";
include "../utils/shiftbytes.circom";

template LastBytesSHA512() {
    signal input in;
    signal output out[16];

    component ntb = Num2Bits(128);
    ntb.in <== in;

    component btb = BitsToBytes(16);
    for(var i = 0; i < 128; i++) {
        btb.in[i] <== ntb.out[i];
    }

    for(var i = 0; i < 16; i++) {
        out[i] <== btb.out[15 - i];
    }
}

template Sha512Prepared(nBlocks) {

    signal input in[nBlocks * 128];
    signal output out[64];
    
    var i;
    var j;
    var k;

    component paddedIn[nBlocks * 128];
    for (i = 0; i < nBlocks * 128; i++) {
        paddedIn[i] = Num2Bits(8);
        paddedIn[i].in <== in[i];
    }


    component ha0 = H512(0);
    component hb0 = H512(1);
    component hc0 = H512(2);
    component hd0 = H512(3);
    component he0 = H512(4);
    component hf0 = H512(5);
    component hg0 = H512(6);
    component hh0 = H512(7);

    component sha512compression[nBlocks];

    for (i=0; i<nBlocks; i++) {

        sha512compression[i] = Sha512compression() ;

        if (i==0) {
            for (k=0; k<64; k++ ) {
                sha512compression[i].hin[0*64+k] <== ha0.out[k];
                sha512compression[i].hin[1*64+k] <== hb0.out[k];
                sha512compression[i].hin[2*64+k] <== hc0.out[k];
                sha512compression[i].hin[3*64+k] <== hd0.out[k];
                sha512compression[i].hin[4*64+k] <== he0.out[k];
                sha512compression[i].hin[5*64+k] <== hf0.out[k];
                sha512compression[i].hin[6*64+k] <== hg0.out[k];
                sha512compression[i].hin[7*64+k] <== hh0.out[k];
            }
        } else {
            for (k=0; k<64; k++ ) {
                sha512compression[i].hin[64*0+k] <== sha512compression[i-1].out[64*0+63-k];
                sha512compression[i].hin[64*1+k] <== sha512compression[i-1].out[64*1+63-k];
                sha512compression[i].hin[64*2+k] <== sha512compression[i-1].out[64*2+63-k];
                sha512compression[i].hin[64*3+k] <== sha512compression[i-1].out[64*3+63-k];
                sha512compression[i].hin[64*4+k] <== sha512compression[i-1].out[64*4+63-k];
                sha512compression[i].hin[64*5+k] <== sha512compression[i-1].out[64*5+63-k];
                sha512compression[i].hin[64*6+k] <== sha512compression[i-1].out[64*6+63-k];
                sha512compression[i].hin[64*7+k] <== sha512compression[i-1].out[64*7+63-k];
            }
        }

        for(j = 0; j < 128; j++) {
            for(k = 0; k < 8; k++) {
                sha512compression[i].inp[j * 8 + k] <== paddedIn[i*128 + j].out[7 - k];
            }
        }
    }


    component bitsToBytes[64];
    for (i = 0; i < 64; i++) {
        bitsToBytes[i] = Bits2Num(8);
        for (j = 0; j < 8; j++) {
            bitsToBytes[i].in[7-j] <== sha512compression[nBlocks-1].out[i*8+j];
        }
        out[i] <== bitsToBytes[i].out;
    }
}

template SHA512Message(nBytes) {
    signal input in[nBytes];
    signal input length;
    signal output out[64];

    var i;
    var nBlocks;


    nBlocks = ((nBytes + 16)\128)+1;

    component pbot = PutBytesOnTop(nBytes, 1);
    
    for(i = 0; i < nBytes; i++) {
        pbot.s1[i] <== in[i];
    }
    pbot.s2[0] <== 128;
    pbot.idx <== length;

    component lb =  LastBytesSHA512();
    lb.in <== length * 8;

    component hp = Sha512Prepared(nBlocks);
    for(i = 0; i < nBytes + 1; i++) {
        hp.in[i] <== pbot.out[i];
    }

    for(i = nBytes + 1; i < 128 * nBlocks - 16; i++) {
        hp.in[i] <== 0;
    }

    for(i = 0; i < 16; i++) {
        hp.in[i + 128 * nBlocks - 16] <== lb.out[i];
    }

    for(i = 0; i < 64; i++) {
        out[i] <== hp.out[i];
    }
}