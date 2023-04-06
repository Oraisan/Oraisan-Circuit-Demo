// SPDX-License-Identifier: GPL-3.0
pragma circom 2.0.0;
include "../../../libs/validators/signaturesverifier.circom";



component main{public[pubKeys, R8, height, blockHash, blockTime]} = AddRHCalculation(5, 5);