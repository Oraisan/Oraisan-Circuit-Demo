const fs = require("fs");
const { addLeaf, getTree, initialize, hash, getSiblings } = require("./fmt");
const { readJSONFilesInFolder, getAddresFromAsciiString } = require("./helper");

const range = (start, stop, step) =>
    Array.from({ length: (stop - start) / step }, (_, i) => start + i * step);


const main = async () => {
    await initialize();
    const tree = getTree();
    let data = readJSONFilesInFolder("test/txs/depositInfo");

    const oldValue = Array.from({ length: 10 }, () => hash([0]));
    console.log(data)
    const newValue = Array.from(data, (data) => hash([data.eth_bridge_address, data.eth_receiver, data.amount, getAddresFromAsciiString(data.cosmos_token_address), data.key]));
    for (i = data.length; i < 10; i++) {
        newValue.push(oldValue[i]);
    }

    const index = 0;
    console.log("default", tree.root());

    for (let i = index; i < index + 5; i++) {
        tree.update(i, newValue[i - index]);
    }

    const oldRoot = tree.root();

    const siblings = [];

    for (let i = index + 5; i < index + 10; i++) {
        tree.update(i, newValue[i - index]);
        siblings.push(getSiblings(i));
    }
    const newRoot = tree.root();

    const input = {
        key: range(index + 5, index + 10, 1),
        newValue: newValue.map(e => e.toString()).slice(5, 10),
        oldRoot: oldRoot,
        siblings: siblings.map(sib => sib.map(e => e.toString())),
        newRoot: newRoot,
    };
    // console.log(input);
    json = JSON.stringify(input, null, 2);
    console.log(json)
};

main()
    .then(() => { })
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });