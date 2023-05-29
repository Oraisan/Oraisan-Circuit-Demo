const { addLeaf, getTree, initialize, hash, getSiblings } = require("./fmt");
const { readJSONFilesInFolder, getAddresFromAsciiString } = require("./helper");


const main = async () => {
    await initialize();
    const tree = getTree();
    const data = readJSONFilesInFolder("test/txs/depositInfo");

    const value = Array.from(data, (data) => hash([data.eth_bridge_address, data.eth_receiver, data.amount, getAddresFromAsciiString(data.cosmos_token_address), data.key]));
    for(let i = 0; i < value.length; i++) {
        tree.insert(value[i]);
    }
    const index = 5;
    

    const siblings = getSiblings(index);

    const input = {
        eth_bridge_address: data[index].eth_bridge_address,
        eth_receiver: data[index].eth_receiver,
        amount: data[index].amount,
        cosmos_token_address: getAddresFromAsciiString(data[index].cosmos_token_address),
        key:  data[index].key,
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