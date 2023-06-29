exports.readJSONFilesInFolder = void 0;
const fs = require("fs");
const crypto = require('crypto');
const path = require('path');

function readJSONFilesInFolder(folderPath) {
    const files = fs.readdirSync(folderPath);
    files.sort(function(a, b) {
        const x_a = Number((a.split("deposit")[1]).split(".json")[0]);
        const x_b = Number((b.split("deposit")[1]).split(".json")[0]);
        return x_a - x_b
    });
    console.log(files)
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

function base64ToBytes(base64) {
    var binaryString = atob(base64);
    var byteArray = new Array(binaryString.length);
  
    for (var i = 0; i < binaryString.length; i++) {
      byteArray[i] = binaryString.charCodeAt(i);
    }
  
    return byteArray;
}
exports.base64ToBytes = base64ToBytes;


function saveJsonData(path, data) {
    console.log(data)
    const jsonData = JSON.stringify(data, (key, value) =>
    typeof value === 'bigint'
        ? value.toString()
        : value
    , 2);

    fs.writeFileSync(path, jsonData, 'utf-8');
    console.log('Data has been saved to file:', path);
}
exports.saveJsonData = saveJsonData;

function getAddresFromAsciiString(asciiString) {
    const hexString = uint8ArrayToHexString(stringToAsciiBytes(asciiString));
    const hash = hashHexStringWithSHA256(hexString)
    return "0x" + hash.slice(0, 40)
}
exports.getAddresFromAsciiString = getAddresFromAsciiString;

