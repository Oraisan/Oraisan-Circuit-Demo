exports.initialize = exports.getTree = exports.numToHex = exports.hash = exports.getSiblings = void 0;

const fs = require("fs");
const { buildMimc7 } = require("circomlibjs");
const { toBufferLE, toBigIntLE, toBigIntBE } = require("bigint-buffer");
const MerkleTree = require("fixed-merkle-tree");
const { randomBytes } = require("crypto");
const BN = require("bn.js");
let mimc;
let F;
let tree;

const initialize = async () => {
    mimc = await buildMimc7();
    F = mimc.F;
    tree = new MerkleTree(32);
}
exports.initialize = initialize;

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
    // return F.toObject(babyJub.unpackPoint(mimc.hash(L, R))[0]);
    return F.toObject(mimc.multiHash(arr, 0));
}
exports.hash = hash;

function randomBigInt(n) {
    return toBigIntLE(randomBytes(n));
}

const addLeaf = async (cccd, sex, DoBdate, BirthPlace) => {
    if (!tree) await initialize();
    const leaf =  hash([cccd, sex, DoBdate, BirthPlace]);
    tree.insert(leaf);
    return tree._layers[0].length - 1;
}
exports.addLeaf = addLeaf;

const getSiblings = (index) => {
    let { pathElements } = tree.path(index);
    return pathElements;
}
exports.getSiblings = getSiblings;
/*

 */
const genAgeInput = (publicKey, cccd, sex, DoBdate, BirthPlace, minAge, maxAge, index) => {

    const leaf = hash([cccd, sex, DoBdate, BirthPlace]);

    let dateObj = new Date();
    let month = dateObj.getUTCMonth() + 1; //months from 1-12
    let day = dateObj.getUTCDate();
    let year = dateObj.getUTCFullYear();



    // console.log(hash(toBufferLE(leaf.publicKey, 20)))

    const { pathElements, pathIndices } = tree.path(index);
    const input = {
        root: tree.root(),
        leaf: numToHex(leaf),
        publicKey: numToHex(publicKey),
        CCCD: Number(cccd),
        sex: Number(sex),
        DoBdate: Number(DoBdate),
        BirthPlace: Number(BirthPlace),

        minAge: minAge,
        maxAge: maxAge,
        challenge: 100,
        currentYear: year,
        currentMonth: month,
        currentDay: day,
        pathElements: pathElements.map(e => e.toString()),
        pathIndices: pathIndices,
    };

    return input;
}
exports.genAgeInput = genAgeInput;
