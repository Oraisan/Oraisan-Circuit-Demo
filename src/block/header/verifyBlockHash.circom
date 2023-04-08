// SPDX-License-Identifier: GPL-3.0
pragma circom 2.0.0;
include "../../libs/validators/msgencodeverifier.circom";

component main{public[height, blockHash, seconds, nanos, msg]} = MsgEncodeVerifierByBytes(9, 111, 40);