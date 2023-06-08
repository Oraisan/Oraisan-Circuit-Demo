// SPDX-License-Identifier: GPL-3.0
pragma circom 2.0.0;
include "../../../libs/Fixed_Merkle_Tree/fmtverifier.circom";
include "../../../libs/Fixed_Merkle_Tree/fmthash.circom";
template VerifyClaimTransaction(nSiblings) {
    
    signal input eth_bridge_address;
    signal input eth_receiver;
    signal input amount;
    signal input eth_token_address;
    signal input key;

    signal input siblings[nSiblings];
    signal input root;
    var i;

    component h = Hash(4);
    h.in[0] <== eth_bridge_address;
    h.in[1] <== eth_receiver;
    h.in[2] <== amount;
    h.in[3] <== eth_token_address;
    
    component r = CalculateRootFromSiblings(nSiblings);
    r.key <== key;
    r.in <== h.out;
    for(i = 0; i < nSiblings; i++) {
        r.siblings[i] <== siblings[i];
    }

    root === r.root;
    
}
component main{public[eth_bridge_address, eth_receiver, amount, eth_token_address, key, root]} = VerifyClaimTransaction(32);
