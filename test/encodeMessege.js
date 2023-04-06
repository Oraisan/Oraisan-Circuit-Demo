const path = require('path');
const wasmTester = require('circom_tester').wasm;
const utils = require('./utils');
const fs = require("fs");
const assert = require('assert');

function getBitsArrayFromHex(a, nBits) {
    let bigN = BigInt(a);
    let bufBigN = utils.bigIntToLEBuffer(bigN).reverse();
    let bitsBigN = utils.pad(utils.buffer2bits(bufBigN), nBits);
    return bitsBigN;
}

function byteToHexString(byteArray) {
    return "0x" + Array.from(byteArray, function (byte) {
        return ('0' + (byte & 0xFF).toString(16)).slice(-2);
    }).join('')
}

function binaryArrayToBytesArray(binaryArray) {
    // Convert the binary array to a string of binary digits
    const binaryString = binaryArray.join("");

    // Split the binary string into an array of 8-bit substrings
    const byteStrings = binaryString.match(/.{1,8}/g);

    // Convert each 8-bit substring to a byte value
    const byteArray = byteStrings.map(byteString => parseInt(byteString, 2));
    return byteArray;
}

function hexStringToBytesArray(hexString) {
    // Convert the hexadecimal string to a binary string
    const binaryString = hexString
    .match(/.{1,2}/g)
    .map(hex => parseInt(hex, 16).toString(2).padStart(8, "0"))
    .join("");

    // Split the binary string into an array of 8-bit substrings
    const byteStrings = binaryString.match(/.{1,8}/g);

    // Convert each 8-bit substring to a byte value
    const byteArray = byteStrings.map(byteString => parseInt(byteString, 2))
    return byteArray;
}
function timeUnitToBitArray(timeUnit) {
    // Convert the integer to a binary string
    const binaryString = timeUnit.toString(2);

    // Split the binary string into an array of bits
    const bitArray = binaryString.split("").map(bit => parseInt(bit));

    // Pad the array with zeros to the desired length of 35 elements
    const paddedBitArray = Array(35 - bitArray.length).fill(0).concat(bitArray);

    // Reverse the order of the bits in the array
    sBits = paddedBitArray.reverse();
    
    // console.log(sBits);
    let timeUnitBits = [];
    for( var i = 0; i < 35; i ++) {
        timeUnitBits.push(sBits[i]);
        if(i % 7 == 6) {
            if(i != 34) timeUnitBits.push(1);
            else timeUnitBits.push(0);
        }
    }
    console.log(timeUnitBits)
    return timeUnitBits;
}

const main = async () => {
    const p = "test/message"
    const cir = await wasmTester(path.join(__dirname, 'message/message_test.circom'));
    // const cir = await wasmTester(path.join(__dirname, path +'/verifier_test.circom'));
    // const cir = await wasmTester(path.join(__dirname, '../electron-labs/test/verifier_test.circom'));
    let height = 10340037;

    let blockHash = hexStringToBytesArray("DDB010FECDA643EFB6E7F0FBCBB0A4AB7F23173F865B40EDF47139A3627E1200");
    let nParts = 1;
    let partsTotal = 1;
    let partsHash = [hexStringToBytesArray("1C426CDC8371B36AFE91A1818812087903B35C6FC6EF998D19FF2DCF6EFA00A5")];
    let seconds = 1676740068;
    let nanos = 514688179;
    let chainID = getBitsArrayFromHex(byteToHexString([79, 114, 97, 105, 99, 104, 97, 105, 110]));
    let message = [110, 8, 2, 17, 197, 198, 157, 0, 0, 0, 0, 0, 34, 72, 10, 32, 221, 176, 16, 254, 205, 166, 67, 239, 182, 231, 240, 251, 203, 176, 164, 171, 127, 35, 23, 63, 134, 91, 64, 237, 244, 113, 57, 163, 98, 126, 18, 0, 18, 36, 8, 1, 18, 32, 28, 66, 108, 220, 131, 113, 179, 106, 254, 145, 161, 129, 136, 18, 8, 121, 3, 179, 92, 111, 198, 239, 153, 141, 25, 255, 45, 207, 110, 250, 0, 165, 42, 12, 8, 228, 139, 196, 159, 6, 16, 179, 137, 182, 245, 1, 50, 9, 79, 114, 97, 105, 99, 104, 97, 105, 110];
    const input = {
        fnc: Array.from({length: 2}, () => 1),
        height: height,
        blockHash: blockHash,
        partsTotal: partsTotal,
        partsHash: partsHash,
        seconds: Array.from({length: 3}, () => seconds),
        nanos: Array.from({length: 3}, () => nanos),
        // chainID: chainID,
        msg: Array.from({length: 3}, () => message)
    }
    
    const json = JSON.stringify(input, null, 2);
    console.log(input.msg[0].length);
    fs.writeFile(p + '/input.json', json, (err) => {
        if (err) {
            console.log(err);
        } else {
            console.log("write successful");
        }
    });

    try {
        const witness = await cir.calculateWitness({
            fnc: input.fnc,
            height: input.height,
            blockHash: input.blockHash,
            partsTotal: input.partsTotal,
            partsHash: input.partsHash,
            seconds: input.seconds,
            nanos: input.nanos,
            // chainID: input.chainID,
            msg: input.msg
        });
        // const witness = await cir.calculateWitness({
        //     P: chunkA
        // });
        // assert.ok(witness.slice(1, 257).every((u, i) => u === res[i]));
    } catch (e) {
        console.log(e)
    }
}
main()
    .then(() => { })
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });