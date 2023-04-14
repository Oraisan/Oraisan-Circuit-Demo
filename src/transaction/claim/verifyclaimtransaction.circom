// SPDX-License-Identifier: GPL-3.0
pragma circom 2.0.0;
include "../../libs/Fixed_Merkle_Tree/fmtverifier.circom";
include "../../libs/Fixed_Merkle_Tree/fmthash.circom";
template VerifyBatchTransaction(nSiblings) {
    signal input key;

    signal input mainchainID;
    signal input sidechainID;
    signal input mainBridgeAddress;
    signal input sideBridgeAddress;
    signal input sideTokenAddress;
    signal input amount;
    signal input receiverAddress;
    signal input indexDepositTx;

    signal input siblings[nSiblings];
    signal input root;
    var i;

    component h = Hash(8);
    h.in[0] <== mainchainID;
    h.in[1] <== sidechainID;
    h.in[2] <== sideTokenAddress;
    h.in[3] <== mainBridgeAddress;
    h.in[4] <== sideBridgeAddress;
    h.in[5] <== amount;
    h.in[6] <== receiverAddress;
    h.in[7] <== indexDepositTx;

    component r = CalculateRootFromSiblings(nSiblings);
    r.key <== key;
    r.in <== h.out;
    for(i = 0; i < nSiblings; i++) {
        r.siblings[i] <== siblings[i];
    }

    root === r.root;
    
}
component main{public[mainchainID, sidechainID, mainBridgeAddress, sideBridgeAddress, sideTokenAddress, amount, receiverAddress, indexDepositTx, indexDepositTx]} = VerifyBatchTransaction(32);
