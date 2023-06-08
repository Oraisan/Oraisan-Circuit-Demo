exports.initialize = exports.getTree = exports.numToHex = exports.hash = exports.getSiblings = void 0;

const fs = require("fs");
const { buildPoseidon } = require("circomlibjs");
const { toBufferLE, toBigIntLE, toBigIntBE } = require("bigint-buffer");
const MerkleTree = require("fixed-merkle-tree");
const { randomBytes } = require("crypto");
const BN = require("bn.js");
let poseidon;
let F;
let tree;


const initialize = async () => {
    poseidon = await buildPoseidon();
    F = poseidon.F;

    const option = {
        hashFunction: hashInner,
        zeroElement: hash([0])
    }
    tree = new MerkleTree(32, undefined, option);
}
exports.initialize = initialize;

function hashInner(left, right) {
    // return F.toObject(babyJub.unpackPoint(poseidon.hash(L, R))[0]);
    return hash([left, right])
}

const getTree = () => {
    return tree;
}
exports.getTree = getTree;

function numToHex(num) {
    const hexStr = num.toString(16);
    const zeroPaddedHexStr = hexStr.padStart(64, "0"); // pad to 32 bytes (64 characters)

    return "0x" + zeroPaddedHexStr;
}

exports.numToHex = numToHex;

function hash(arr) {
    // return F.toObject(babyJub.unpackPoint(poseidon.hash(L, R))[0]);
    const h = F.e(poseidon([...arr]));
    const res = BigInt("0x" + F.toObject(h).toString('16')).toString()
    return res;
}
exports.hash = hash;

function randomBigInt(n) {
    return toBigIntLE(randomBytes(n));
}

const addLeaf = async (cccd, sex, DoBdate, BirthPlace) => {
    // if (!tree) await initialize();
    // const leaf =  hash([cccd, sex, DoBdate, BirthPlace]);
    // tree.insert(leaf);
    // return tree._layers[0].length - 1;
}
exports.addLeaf = addLeaf;

const getSiblings = (index) => {
    let { pathElements } = tree.path(index);
    return pathElements;
}
exports.getSiblings = getSiblings;
/*

 */
