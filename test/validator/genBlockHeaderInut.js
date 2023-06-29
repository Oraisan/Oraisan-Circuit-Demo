const path = require('path');
// const wasmTester = require('circom_tester').wasm;
const utils = require('../utils');
const { saveJsonData } = require('../helper');
const fs = require("fs");
const assert = require('assert');

const main = async () => {
    const p = "electron-labs/test/verify"
    // const cir = await wasmTester(path.join(__dirname, '../electron-labs/test/compress/pointcompress_test.circom'));
    // const cir = await wasmTester(path.join(__dirname, path +'/verifier_test.circom'));
    // const cir = await wasmTester(path.join(__dirname, '../electron-labs/test/verifier_test.circom'));
    const pointA = [
        53714668321720706063057965111678326220400594841872319580977336133569829600985n,
        34844027024581512423726526638539177039294119883067873667957989240036408132750n,
        1n,
        11045611804130626566084447765697557835534201715967222215387234142916103312307n
    ];
    const pointR = [
        56184354741927938172928048139394271995747217531650824231038756306697178047941n,
        25073708662255953000486391043371697656898547923524051744858758338488374117314n,
        1n,
        8805366489026379402570436569662971098695100559086298461457148742171730410306n
    ];
    const pointG = [
        15112221349535400772501151409588531511454012693041857206046113283949847762202n,
        46316835694926478169428394003475163141307993866256225615783033603165251855960n,
        1n,
        46827403850823179245072216630277197565144205554125654976674165829533817101731n
    ]
    const A = BigInt("0x8E8467B481F13DFD0404D8B8D9A454C44F9A57A0F771BF4320BDFF8A390509CD");
    const msg = BigInt("0x76080211797dc8000000000022480a2044228740639b9dcd33134993d05c2465598d0ebb1a4697266b64b5f34b341696122408011220fe430cd1121065d06dbc7399161ab3b9a4d1961853d3e69e0d4eee13138db67b2a0c08b9d3b8a30610a5f4dfce0232114f726169636861696e2d746573746e6574");
    const R8 = BigInt("0xc2c33314196aa002e452dee9cc0c1d2d088ec86ba7ec2a41824ce5e757376fb7");
    const S = BigInt("0xad7295d02a1b7b35df134a8fe2bbc451662d29c696b5f924c2635ea84ef7d105");
    // console.log(A)
    // console.log("msg", msg.toString("16"))
    // console.log("r8", R8.toString("16"))
    // console.log("S", S.toString("16"))
    // const bufMsg = utils.bigIntToLEBuffer(msg).reverse();
    // const bufR8 = utils.bigIntToLEBuffer(R8).reverse();
    // const bufS = utils.bigIntToLEBuffer(S).reverse();
    // const bufA = utils.bigIntToLEBuffer(A).reverse();
    // const bitsMsg = utils.buffer2bits(bufMsg, 888).reverse();
    // const bitsR8 = utils.pad(utils.buffer2bits(bufR8), 256);
    // const bitsS = utils.pad(utils.buffer2bits(bufS), 255).slice(0, 255);
    // const bitsA = utils.pad(utils.buffer2bits(bufA), 256);
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
        // msg: bitsMsg,
        // A: bitsA,
        // R8: bitsR8,
        // S: bitsS,
        PointA: chunkA,
        PointR: chunkR,
    }

    console.log(input);
    // saveJsonData(p + "input.json", input)

    // try {
    //     const witness = await cir.calculateWitness({
    //         P: chunkR,
    //         A: bitsR8
    //     });
    //     // const witness = await cir.calculateWitness({
    //     //     P: chunkA
    //     // });
    //     // assert.ok(witness.slice(1, 257).every((u, i) => u === res[i]));
    // } catch (e) {
    //     console.log(e)
    // }
 }
main()
    .then(() => { })
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });