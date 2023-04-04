// SPDX-License-Identifier: GPL-3.0
pragma circom 2.0.0;
include "../../src/libs/validators/msgencodeverifier.circom";

component main{public[height]} = MsgEncodeVerifierByBytes(111, 40);