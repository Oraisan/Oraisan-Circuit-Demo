// SPDX-License-Identifier: GPL-3.0
pragma circom 2.0.0;
include "../calculateblockhash.circom";

component main{public[in]} = CalculateRootFromLeafs(2);