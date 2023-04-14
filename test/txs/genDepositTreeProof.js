const fs = require("fs");
const { addLeaf, getTree, initialize, hash, getSiblings } = require("./fmt");

const range = (start, stop, step) =>
    Array.from({ length: (stop - start) / step }, (_, i) => start + i * step);

const main = async () => {
    await initialize();
    const tree = getTree();
    const data = [
        {
            cccd: 696056340923n,
            sex: 1n,
            DoBdate: 20010825n,
            BirthPlace: 842605n
        },
        {
            cccd: 696056340923n,
            sex: 1n,
            DoBdate: 20010825n,
            BirthPlace: 842605n
        },
        {
            cccd: 696056340923n,
            sex: 1n,
            DoBdate: 20010825n,
            BirthPlace: 842605n
        },
        {
            cccd: 696056340923n,
            sex: 1n,
            DoBdate: 20010825n,
            BirthPlace: 842605n
        },
        {
            cccd: 696056340923n,
            sex: 1n,
            DoBdate: 20010825n,
            BirthPlace: 842605n
        }
    ]

    const oldValue = Array.from({ length: data.length }, () => hash([0]));
    const newValue = Array.from(data, (data) => hash([data.cccd, data.sex, data.DoBdate, data.BirthPlace]));
    const index = 0;

    tree.update(index, oldValue[0]);
    const oldRoot = tree.root();
    const siblings = [];

    for (let i = index; i < index + data.length; i++) {
        tree.update(i, newValue[i]);
        siblings.push(getSiblings(i));
    }
    const newRoot = tree.root();

    const input = {
        key: range(index, index + data.length, 1),
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