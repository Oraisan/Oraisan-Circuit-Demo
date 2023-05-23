const fs = require("fs");
const { addLeaf, getTree, initialize, hash, getSiblings } = require("./fmt");

const range = (start, stop, step) =>
    Array.from({ length: (stop - start) / step }, (_, i) => start + i * step);

function base64ToHex(str) {
    const result = Buffer.from(str, 'base64').toString("hex") ;
    return result;
}
const main = async () => {
    await initialize();
    const tree = getTree();
    const data = [
        {
            eth_bridge_address: "0xde408146A0a44cC991C6CA8A1C9b25117dBAB295",
            eth_receiver: "0xde408146A0a44cC991C6CA8A1C9b25117dBAB295",
            amount: 10,
            cosmos_token_address: "0xde408146A0a44cC991C6CA8A1C9b25117dBAB295",
            key: 0
        },
    ]

    if(data.length > 5) {
        data = data.slice(0, 5);
    }

    const oldValue = Array.from({ length: 5 }, () => hash([0]));
    const newValue = Array.from(data, (data) => hash([data.eth_bridge_address, data.eth_receiver, data.amount, data.cosmos_token_address, data.key]));
    for(i = data.length; i < 5; i++) {
        newValue.push(oldValue[i]);
    }

    const index = 0;
    console.log("default", tree.root());
    
    tree.update(index, oldValue[0]);
    const oldRoot = tree.root();
    
    const siblings = [];

    for (let i = index; i < index + 5; i++) {
        tree.update(i, newValue[i - index]);
        siblings.push(getSiblings(i));
    }
    const newRoot = tree.root();

    const input = {
        key: range(index, index + 5, 1),
        oldValue: oldValue.map(e => e.toString()),
        newValue: newValue.map(e => e.toString()),
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