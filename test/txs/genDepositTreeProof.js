const fs = require("fs");
const { addLeaf, getTree, initialize, hash, getSiblings } = require("./fmt");
const { readJSONFilesInFolder, getAddresFromAsciiString, saveJsonData } = require("./helper");

const range = (start, stop, step) =>
    Array.from({ length: (stop - start) / step }, (_, i) => start + i * step);
const depositTree = require("./depositTree/deposit_tree.json");

const main = async () => {
    await initialize();
    const tree = getTree();
    let data = readJSONFilesInFolder("./test/txs/depositInfo");
    
    let n_leafs = depositTree.n_leafs;
    let nqueue_leafs = depositTree.nqueue_leafs
    let nmax_leafs_update = 5;

    const newValue = Array.from(data, (data) => hash([data.eth_bridge_address, data.eth_receiver, data.amount, data.eth_token_address]));

    for (i = nqueue_leafs; i < nmax_leafs_update; i++) {
        newValue.push(hash([0]));
    }

    for (let i = 0; i < n_leafs; i++) {
        tree.update(i, newValue[i]);
    }

    if(n_leafs == 0) {
        tree.update(0, hash([0]));
    }

    const oldRoot = tree.root();

    const siblings = [];
    console.log(newValue);
    for (let i = n_leafs; i < n_leafs + nmax_leafs_update; i++) {
        tree.update(i, newValue[i]);
        siblings.push(getSiblings(i));
    }
    const newRoot = tree.root();

    const input = {
        key: range(n_leafs, n_leafs + nmax_leafs_update, 1),
        newValue: newValue.map(e => e.toString()).slice(n_leafs, n_leafs +  nmax_leafs_update),
        oldRoot: oldRoot,
        siblings: siblings.map(sib => sib.map(e => e.toString())),
        newRoot: newRoot,
    };
    
    saveJsonData("./src/transaction/transactioncosmos/verifyRootBatchTxsCosmos/input.json", input)
};

main()
    .then(() => { })
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });