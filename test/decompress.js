const path = require('path');
const wasmTester = require('circom_tester').wasm;
const utils = require('./utils');
const fs = require("fs");
const assert = require('assert');

const main = async () => {
    const path = "electron-labs/test/verify"
    // const cir = await wasmTester(path.join(__dirname, '../electron-labs/test/compress/pointcompress_test.circom'));
    // const cir = await wasmTester(path.join(__dirname, path +'/verifier_test.circom'));
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
    const pointG = [
        15112221349535400772501151409588531511454012693041857206046113283949847762202n,
        46316835694926478169428394003475163141307993866256225615783033603165251855960n,
        1n,
        46827403850823179245072216630277197565144205554125654976674165829533817101731n
    ]
    const A = BigInt("0x0aa783be7826b9c8808bf36150f63945b23e3db445f5a84186a1239e304e28fd");
    const msg = BigInt("0x6e080211c5c69d000000000022480a20ddb010fecda643efb6e7f0fbcbb0a4ab7f23173f865b40edf47139a3627e12001224080112201c426cdc8371b36afe91a1818812087903b35c6fc6ef998d19ff2dcf6efa00a52a0c08e48bc49f0610b389b6f50132094f726169636861696e");
    const R8 = BigInt("0x1dc724b254a6734c1e470f20339333011e429576b3f5016c5c857bff1abfd189");
    const S = BigInt("0xcc2ef5452e54a95e9bf0f861acbfd4f8bfcc75260cb5bdc7d06d654481a76104");
    console.log(A)
    console.log("msg", msg)
    console.log("r8", R8)
    console.log("S", S)
    const bufMsg = utils.bigIntToLEBuffer(msg);
    const bufR8 = utils.bigIntToLEBuffer(R8);
    const bufS = utils.bigIntToLEBuffer(S);
    const bufA = utils.bigIntToLEBuffer(A);
    const bitsMsg = utils.buffer2bits(bufMsg, 888);
    const bitsR8 = utils.pad(utils.buffer2bits(bufR8), 256);
    const bitsS = utils.pad(utils.buffer2bits(bufS), 255).slice(0, 255);
    const bitsA = utils.pad(utils.buffer2bits(bufA), 256);
    const chunkA = [];
    const chunkR = [];
    const chunkG = [];

    for (let i = 0; i < 4; i++) {
        chunkA.push(utils.chunkBigInt(pointA[i], BigInt(2 ** 85)));
        chunkR.push(utils.chunkBigInt(pointR[i], BigInt(2 ** 85)));
        chunkG.push(utils.chunkBigInt(pointG[i], BigInt(2 ** 85)));
    }

    for (let i = 0; i < 4; i++) {
        utils.pad(chunkA[i], 3);
        utils.pad(chunkR[i], 3);
        utils.pad(chunkG[i], 3);
    }

    const input = {
        msg: bitsMsg,
        A: bitsA,
        R8: bitsR8,
        S: bitsS,
        PointA: chunkA,
        PointR: chunkR,
    }

    const json = JSON.stringify(input, null, 2);
    // console.log(json);
    fs.writeFile(path + '/input.json', json, (err) => {
        if (err) {
            console.log(err);
        } else {
            console.log("write successful");
        }
    });

//     const res = utils.point_compress(pointA);
//     console.log(res)
//     try {
//         const witness = await cir.calculateWitness({
//             input
//         });
//         // const witness = await cir.calculateWitness({
//         //     P: chunkA
//         // });
//         // assert.ok(witness.slice(1, 257).every((u, i) => u === res[i]));
//     } catch (e) {
//         console.log(e)
//     }
 }
main()
    .then(() => { })
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });