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
    const value = Array.from(data, (data) => hash([data.eth_bridge_address, data.eth_receiver, data.amount, data.cosmos_token_address, data.key]));
    
    const index = 0;
    
    tree.insert(value);

    const siblings = getSiblings(index);

    const input = {
        eth_bridge_address: "0xde408146A0a44cC991C6CA8A1C9b25117dBAB295",
        eth_receiver: "0xde408146A0a44cC991C6CA8A1C9b25117dBAB295",
        amount: 10,
        
        key: index,
        siblings: siblings.map(e => e.toString()),
        root: tree.root()
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