const path = require('path');
const wasmTester = require('circom_tester').wasm;
const utils = require('./utils');
const fs = require("fs");

function binaryArrayToBytesArray(binaryArray) {
    // Convert the binary array to a string of binary digits
    const binaryString = binaryArray.join("");

    // Split the binary string into an array of 8-bit substrings
    const byteStrings = binaryString.match(/.{1,8}/g);
    // Convert each 8-bit substring to a byte value
    const byteArray = byteStrings.map(byteString => {
        return parseInt(byteString.split("").reverse().join(""), 2);
    });
    return byteArray;
}

const main = async () => {
    // const cir = await wasmTester(path.join(__dirname, '../electron-labs/test/verifier_test.circom'));
    const pointA = [
        19609600535639426967582330360073854330664420980290928614443703354937550235772n,
        4819101209465356224883271557990864103528016550052741516590013689083114432765n,
        1n,
        51169037833951159944323311113976941583233159633603343645972292487679672161224n,
    ];
    const pointR = [
        37880392645989658068752609291251083631204709745327980624473693943571704213899n,
        4441405635204378107364157117381717143569046592695380934007350497764283041565n,
        1n,
        29423111549617446375779108146631000784035658644093037228114776583127667239194n,
    ];
    const A = BigInt("0xFD284E309E23A18641A8F545B43D3EB24539F65061F38B80C8B92678BE83A70A");
    const msg = BigInt("0x6e080211c5c69d000000000022480a20ddb010fecda643efb6e7f0fbcbb0a4ab7f23173f865b40edf47139a3627e12001224080112201c426cdc8371b36afe91a1818812087903b35c6fc6ef998d19ff2dcf6efa00a52a0c08e48bc49f0610b389b6f50132094f726169636861696e");
    const R8 = BigInt("0x1dc724b254a6734c1e470f20339333011e429576b3f5016c5c857bff1abfd189");
    const S = BigInt("0xcc2ef5452e54a95e9bf0f861acbfd4f8bfcc75260cb5bdc7d06d654481a76104");
    console.log(A)
    console.log("msg", msg.toString("16"))
    console.log("r8", R8.toString("16"))
    console.log("S", S.toString("16"))
    const bufMsg = utils.bigIntToLEBuffer(msg).reverse();
    const bufR8 = utils.bigIntToLEBuffer(R8).reverse();
    const bufS = utils.bigIntToLEBuffer(S).reverse();
    const bufA = utils.bigIntToLEBuffer(A).reverse();
    const bitsMsg = utils.buffer2bits(bufMsg, 888);
    const bitsR8 = utils.pad(utils.buffer2bits(bufR8), 256);
    const bitsS = utils.pad(utils.buffer2bits(bufS), 255).slice(0, 255);
    const bitsA = utils.pad(utils.buffer2bits(bufA), 256);
    const chunkA = [];
    const chunkR = [];

    for (let i = 0; i < 4; i++) {
        chunkA.push(utils.chunkBigInt(pointA[i], BigInt(2 ** 85)));
        chunkR.push(utils.chunkBigInt(pointR[i], BigInt(2 ** 85)));
    }

    for (let i = 0; i < 4; i++) {
        utils.pad(chunkA[i], 3);
        utils.pad(chunkR[i], 3);
    }

    // console.log(bitsMsg.length)
    // console.log(bitsA.length)
    // console.log(bitsR8.length)
    // console.log(bitsS.length)
    // console.log(chunkA.length)
    // console.log(chunkR.length)
    // console.log(chunkG)
    // console.log(bufR8)
    const input = {
        msg:  binaryArrayToBytesArray(bitsMsg),
        pubKeys: binaryArrayToBytesArray(bitsA),
        R8: binaryArrayToBytesArray(bitsR8),
        S: binaryArrayToBytesArray(bitsS),
        PointA: chunkA,
        PointR: chunkR
    }
    
    console.log(input);
    const json = JSON.stringify(input, null, 2);
    // console.log(json);
    fs.writeFile('src/block/input.json', json, (err) => {
        if (err) {
            console.log(err);
        } else {
            console.log("write successful");
        }
    });
    // console.log(bufS)
    // console.log(bitsS)
    
    // try {
    //     const startTime = performance.now();
    //     const witness = await cir.calculateWitness({
    //         msg: bitsMsg, A: bitsA, R8: bitsR8, S: bitsS, PointA: chunkA, PointR: chunkR,
    //     });
    //     const endTime = performance.now();
    //     mlog.success(`Call to calculate witness took ${endTime - startTime} milliseconds`);
    //     assert.ok(witness[0] === 1n);
    //     assert.ok(witness[1] === 1n);
    // } catch (e) {
    //     mlog.error(e);
    //     assert.ok(false);
    // }
}
main()
    .then(() => { })
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });