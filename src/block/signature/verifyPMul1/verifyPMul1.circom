// SPDX-License-Identifier: GPL-3.0
pragma circom 2.0.0;
include "../../../libs/validators/signaturesverifier.circom";

component main{public[addRH, S]} = PMul1Verifier();