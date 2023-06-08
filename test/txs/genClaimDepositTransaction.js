const { addLeaf, getTree, initialize, hash, getSiblings } = require("./fmt");
const { readJSONFilesInFolder, getAddresFromAsciiString, saveJsonData } = require("./helper");

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

    for (let i = n_leafs; i < n_leafs + nmax_leafs_update; i++) {
        tree.update(i, newValue[i]);
    }

    const index = 0;

    const siblings = getSiblings(index);

    const input = {
        eth_bridge_address: data[index].eth_bridge_address,
        eth_receiver: data[index].eth_receiver,
        amount: data[index].amount,
        eth_token_address: data[index].eth_token_address,
        key:  data[index].key,
        siblings: siblings.map(e => e.toString()),
        root: tree.root()
    };
    // console.log(input);
    json = JSON.stringify(input, (key, value) =>
    typeof value === 'bigint'
        ? value.toString()
        : value
    , 2);
    console.log(json)
    saveJsonData("./src/transaction/transactioneth/verifyClaimTransaction/input.json", input)
};

main()
    .then(() => { })
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });