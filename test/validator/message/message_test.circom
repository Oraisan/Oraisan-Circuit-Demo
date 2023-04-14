// SPDX-License-Identifier: GPL-3.0
pragma circom 2.0.0;
include "../../src/libs/validators/msgencodeverifier.circom";

component main{public[fnc, height, blockHash, msg]} = MsgEncodeVerifierByBytes(111, 3);