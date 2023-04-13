pragma circom 2.0.0;
include "./fmthash.circom";
include "../../../node_modules/circomlib/circuits/switcher.circom";
include "../../../node_modules/circomlib/circuits/bitify.circom";

template CalculateRootFromSiblings(nSiblings) {
    signal input key;
    signal input in;
    signal input siblings[nSiblings];
    signal output root;

    component n2bNew = Num2Bits(nSiblings);
    n2bNew.in <== key;

    component selectors[nSiblings];
    component hashers[nSiblings];

    for (var i = 0; i < nSiblings; i++) {
        selectors[i] = Switcher();
        selectors[i].R <== siblings[i];
        selectors[i].L <== i == 0 ? in : hashers[i - 1].out;
        selectors[i].sel <== n2bNew.out[i];

        hashers[i] = HashInner();
        hashers[i].L <== selectors[i].outL;
        hashers[i].R <== selectors[i].outR;
    }

    root <== hashers[nSiblings - 1].out;
}

template CalculateRootFromLeafs(nLeafs) {
    checkNLeafs(nLeafs) === 1;
    
    signal input in[nLeafs];
    signal output out;
    var i;
    var j;
    
    component left;
    component right;
    component parrent;

    if(nLeafs == 1) {
        out <== in[0];
    } else {
        var k = nLeafs/2;
        left = CalculateRootFromLeafs(k);
        for(i = 0; i < k; i++) {
            left.in[i] <== in[i];
        }

        right = CalculateRootFromLeafs(nLeafs - k);
        for(i = k; i < nLeafs; i++) {
            right.in[i-k] <== in[i];
        }

        parrent = HashInner();
        parrent.L <== left.out;
        parrent.R <== right.out;

        out <== parrent.out;
    }
}

function checkNLeafs(nLeafs) {
    var i = 1;
    for(i = 1; i * 2 < nLeafs; i *= 2) {
        
    }
    return i == nLeafs;
}