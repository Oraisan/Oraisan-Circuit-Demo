pragma circom 2.0.0;

include "../../../node_modules/circomlib/circuits/sha256/constants.circom";
include "../../../node_modules/circomlib/circuits/sha256/sha256compression.circom";
include "../../../node_modules/circomlib/circuits/bitify.circom";

template LastBytesSHA256() {
    signal input in;
    signal output out[8];

    component ntb = Num2Bits(64);
    ntb.in <== in;

    component btb = BitsToBytes(8);
    for(var i = 0; i < 64; i++) {
        btb.in[i] <== ntb.out[i];
    }

    for(var i = 0; i < 8; i++) {
        out[i] <== btb.out[7 - i];
    }
}

template Sha256Prepared(nBlocks) {
    signal input in[64 * nBlocks];
    signal output out[32];
    
    var i;
    var j;
    var k;
    
    component paddedIn[64 * nBlocks];
    for (var i = 0; i < 64 * nBlocks; i++) {
        paddedIn[i] = Num2Bits(8);
        paddedIn[i].in <== in[i];
    }

    component ha0 = H(0);
    component hb0 = H(1);
    component hc0 = H(2);
    component hd0 = H(3);
    component he0 = H(4);
    component hf0 = H(5);
    component hg0 = H(6);
    component hh0 = H(7);

    component sha256compression[nBlocks];

    for (i=0; i<nBlocks; i++) {

        sha256compression[i] = Sha256compression() ;

        if (i==0) {
            for (k=0; k<32; k++ ) {
                sha256compression[i].hin[0*32+k] <== ha0.out[k];
                sha256compression[i].hin[1*32+k] <== hb0.out[k];
                sha256compression[i].hin[2*32+k] <== hc0.out[k];
                sha256compression[i].hin[3*32+k] <== hd0.out[k];
                sha256compression[i].hin[4*32+k] <== he0.out[k];
                sha256compression[i].hin[5*32+k] <== hf0.out[k];
                sha256compression[i].hin[6*32+k] <== hg0.out[k];
                sha256compression[i].hin[7*32+k] <== hh0.out[k];
            }
        } else {
            for (k=0; k<32; k++ ) {
                sha256compression[i].hin[32*0+k] <== sha256compression[i-1].out[32*0+31-k];
                sha256compression[i].hin[32*1+k] <== sha256compression[i-1].out[32*1+31-k];
                sha256compression[i].hin[32*2+k] <== sha256compression[i-1].out[32*2+31-k];
                sha256compression[i].hin[32*3+k] <== sha256compression[i-1].out[32*3+31-k];
                sha256compression[i].hin[32*4+k] <== sha256compression[i-1].out[32*4+31-k];
                sha256compression[i].hin[32*5+k] <== sha256compression[i-1].out[32*5+31-k];
                sha256compression[i].hin[32*6+k] <== sha256compression[i-1].out[32*6+31-k];
                sha256compression[i].hin[32*7+k] <== sha256compression[i-1].out[32*7+31-k];
            }
        }

        for(j = 0; j < 64; j++) {
            for(k = 0; k < 8; k++) {
                sha256compression[i].inp[j * 8 + k] <== paddedIn[i*64 + j].out[7 - k];
            }
        }
    }

    component bitsToBytes[32];
    for (var i = 0; i < 32; i++) {
        bitsToBytes[i] = Bits2Num(8);
        for (var j = 0; j < 8; j++) {
            bitsToBytes[i].in[7-j] <== sha256compression[nBlocks-1].out[i*8+j];
        }
        out[i] <== bitsToBytes[i].out;
    }
}

template SHA256Message(nBytes) {
    signal input in[nBytes];
    signal input length;
    signal output out[32];

    var i;
    var nBlocks;


    nBlocks = ((nBytes + 8)\64)+1;

    component pbot = PutBytesOnTop(nBytes, 1);
    
    for(i = 0; i < nBytes; i++) {
        pbot.s1[i] <== in[i];
    }
    pbot.s2[0] <== 128;
    pbot.idx <== length;

    component lb =  LastBytesSHA256();
    lb.in <== length * 8;

    component hp = Sha256Prepared(nBlocks);
    for(i = 0; i < nBytes + 1; i++) {
        hp.in[i] <== pbot.out[i];
    }

    for(i = nBytes + 1; i < 64 * nBlocks - 8; i++) {
        hp.in[i] <== 0;
    }

    for(i = 0; i < 8; i++) {
        hp.in[i + 64 * nBlocks - 8] <== lb.out[i];
    }

    for(i = 0; i < 32; i++) {
        out[i] <== hp.out[i];
    }
}
