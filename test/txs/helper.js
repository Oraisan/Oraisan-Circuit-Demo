exports.readJSONFilesInFolder = void 0;
const fs = require("fs");
const crypto = require('crypto');
const path = require('path');

function readJSONFilesInFolder(folderPath) {
    const files = fs.readdirSync(folderPath);
    const jsonFiles = files.filter(file => path.extname(file) === '.json');

    const jsonData = [];

    jsonFiles.forEach(file => {
        const filePath = path.join(folderPath, file);
        const fileData = fs.readFileSync(filePath, 'utf-8');

        try {
            const parsedData = JSON.parse(fileData);
            jsonData.push(parsedData);
        } catch (error) {
            console.error(`Error parsing JSON file ${file}: ${error}`);
        }
    });

    return jsonData;
}
exports.readJSONFilesInFolder = readJSONFilesInFolder;

const range = (start, stop, step) =>
    Array.from({ length: (stop - start) / step }, (_, i) => start + i * step);

const hexStringToBytes = (hexString) => {
    const bytes = [];
    for (let i = 0; i < hexString.length; i += 2) {
        const byte = parseInt(hexString.substr(i, 2), 16);
        bytes.push(byte);
    }
    return bytes;
}

const hashHexStringWithSHA256 = (hexString) => {
    const bytes = hexStringToBytes(hexString);
    const hash = crypto.createHash('sha256').update(Buffer.from(bytes)).digest('hex');
    return hash;
}

function stringToAsciiBytes(str) {
    const bytes = new Uint8Array(str.length);
    for (let i = 0; i < str.length; i++) {
        bytes[i] = str.charCodeAt(i);
    }
    return bytes;
}

function uint8ArrayToHexString(uint8Array) {
    let hexString = "";
    for (let i = 0; i < uint8Array.length; i++) {
        const hex = uint8Array[i].toString(16).padStart(2, "0");
        hexString += hex;
    }
    return hexString;
}

function base64ToHex(str) {
    const result = Buffer.from(str, 'base64').toString("hex") ;
    return result;
}

function getAddresFromAsciiString(asciiString) {
    const hexString = uint8ArrayToHexString(stringToAsciiBytes(asciiString));
    const hash = hashHexStringWithSHA256(hexString)
    return "0x" + hash.slice(0, 40)
}
exports.getAddresFromAsciiString = getAddresFromAsciiString;

