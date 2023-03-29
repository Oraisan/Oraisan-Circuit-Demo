const crypto = require("crypto");
const wasm_tester = require("circom_tester").wasm;
const buildEddsa = require("circomlibjs").buildEddsa;
const buildBabyjub = require("circomlibjs").buildBabyjub;
const path = require("path");

function buffer2bitArray(b) {
    const res = [];
    for (let i = 0; i < b.length; i++) {
        for (let j = 0; j < 8; j++) {
            res.push((b[i] >> (7 - j) & 1));
        }
    }
    return res;
}


function bitArray2buffer(a) {
    const len = Math.floor((a.length - 1) / 8) + 1;
    const b = new Buffer.alloc(len);

    for (let i = 0; i < a.length; i++) {
        const p = Math.floor(i / 8);
        b[p] = b[p] | (Number(a[i]) << (7 - (i % 8)));
    }
    return b;
}

function buffer2bits(buff) {
    const res = [];
    for (let i = 0; i < buff.length; i++) {
        for (let j = 0; j < 8; j++) {
            if ((buff[i] >> j) & 1) {
                res.push(1n);
            } else {
                res.push(0n);
            }
        }
    }
    return res;
}

function getBitArrayFromByteArray(byteArray) {
    // Create a new array to hold the binary representation of the input bytes
    const binaryArray = [];

    // Iterate over each byte in the input array and convert it to a binary string
    for (let i = 0; i < byteArray.length; i++) {
        const binaryString = byteArray[i].toString(2).padStart(8, '0');

        // Split the binary string into an array of bits and add it to the binary array
        binaryArray.push(...binaryString.split('').map(bit => parseInt(bit)));
    }
    return binaryArray
}
const main = async () => {
    eddsa = await buildEddsa();
    babyJub = await buildBabyjub();
    F = babyJub.F;
    circuit = await wasm_tester(path.join(__dirname, "eddsa_test.circom"));
    const msg = Buffer.from([
        110, 8, 2, 17, 197, 198, 157, 0, 0, 0, 0, 0, 34, 72, 10, 32, 221, 176, 16,
        254, 205, 166, 67, 239, 182, 231, 240, 251, 203, 176, 164, 171, 127, 35, 23,
        63, 134, 91, 64, 237, 244, 113, 57, 163, 98, 126, 18, 0, 18, 36, 8, 1, 18,
        32, 28, 66, 108, 220, 131, 113, 179, 106, 254, 145, 161, 129, 136, 18, 8,
        121, 3, 179, 92, 111, 198, 239, 153, 141, 25, 255, 45, 207, 110, 250, 0,
        165, 42, 12, 8, 228, 139, 196, 159, 6, 16, 179, 137, 182, 245, 1, 50, 9, 79,
        114, 97, 105, 99, 104, 97, 105, 110
    ]);
    //        const prvKey = crypto.randomBytes(32);

    // publicKeyBytes is the byte array containing the public key
    // const publicKeyBytes = new Uint8Array( [
    //     253, 40, 78, 48, 158, 35, 161, 134, 65, 168, 245, 69, 180, 61, 62, 178, 69,
    //     57, 246, 80, 97, 243, 139, 128, 200, 185, 38, 120, 190, 131, 167, 10
    //   ]);


    // const publicKeyUint8Array = new Uint8Array(publicKeyBytes.buffer, 0, 32);
    // // console.log(publicKeyUint8Array)
    // const prvKey = Buffer.from("0001020304050607080900010203040506070809000102030405060708090001", "hex");

    // const pubKey = eddsa.prv2pub(prvKey);
    // // console.log(pubKey)
    // const pPubKey = babyJub.packPoint(pubKey);
    // // console.log(pPubKey)

    // const signature = eddsa.signPedersen(prvKey, msg);
    // console.log(signature)
    // const pSignature = eddsa.packSignature(signature);
    // const uSignature = eddsa.unpackSignature(pSignature);

    // console.log(eddsa.verifyPedersen(msg, uSignature, pubKey));

    const msgBits = buffer2bits(msg);
    // const r8Bits = buffer2bits(pSignature.slice(0, 32));
    // const sBits = buffer2bits(pSignature.slice(32, 64));
    // const aBits = buffer2bits(pPubKey);

    const sig = new Uint8Array([
        29, 199, 36, 178, 84, 166, 115, 76, 30, 71, 15, 32, 51, 147, 51, 1, 30, 66,
        149, 118, 179, 245, 1, 108, 92, 133, 123, 255, 26, 191, 209, 137, 204, 46,
        245, 69, 46, 84, 169, 94, 155, 240, 248, 97, 172, 191, 212, 248, 191, 204,
        117, 38, 12, 181, 189, 199, 208, 109, 101, 68, 129, 167, 97, 4
    ])

    const pubkey = new Uint8Array([
        253, 40, 78, 48, 158, 35, 161, 134, 65, 168, 245, 69, 180, 61, 62, 178, 69,
        57, 246, 80, 97, 243, 139, 128, 200, 185, 38, 120, 190, 131, 167, 10
    ])
    const sigs = getBitArrayFromByteArray(sig)
    const r8Bits = sigs.slice(0, 256)

    const sBits = sigs.slice(256, 512)

    const aBits = getBitArrayFromByteArray(pubkey)


    // console.log(aBits)


    const w = await circuit.calculateWitness({ A: aBits, R8: r8Bits, S: sBits, msg: msgBits }, true);

    // await circuit.checkConstraints(w);
    // const cir = await wasm_tester(path.join(__dirname, "../src/libs/AVL_Tree/avlverifier.circom"));
    // const b = new Buffer.alloc();
    // for (let i = 0; i < 1; i++) {
    //     b[i] = 0;
    // }
    // const b = Buffer.from("2e3764b0e784b5b5a4cb5b22e65d056a56ba7c09de0ea8d9ffeb11aa52f1e132", "hex")
    // const valueBits = buffer2bitArray(b);
    // // console.log(valueBits);
    // console.log(b.toJSON().data)
    // const leaf = crypto.createHash("sha256").update(Buffer.from("002e3764b0e784b5b5a4cb5b22e65d056a56ba7c09de0ea8d9ffeb11aa52f1e132", "hex")).digest("hex");
    // // const leafBits = buffer2bitArray(Buffer.from(leaf.toString(), "hex"));
    // const siblings = buffer2bitArray(Buffer.from("4bc0910cabfbbe8c14bed0cf70eeb487a933c15ba8cfccdc1cac07723f6e38c4", "hex"));
    // const root = buffer2bitArray(Buffer.from("945e52128727280e8594fd66bd57294f843c81f872f1233dd8824fa8b82e7cd0", "hex"));
    // console.log(root)
    // const witness = await cir.calculateWitness({
    //     "root": root,
    //     "siblings": siblings,
    //     "key": 0,
    //     "valueBits": valueBits,
    // }, true);
    // const roottest = "01".concat(leaf).concat("4bc0910cabfbbe8c14bed0cf70eeb487a933c15ba8cfccdc1cac07723f6e38c4");
    // console.log(leaf)
    // console.log(roottest)
    // console.log(crypto.createHash("sha256").update(Buffer.from(roottest, "hex")).digest("hex"))
    // const arrIn = buffer2bitArray(b).toString("hex");
    // console.log(b.toString("hex"));
    // console.log(bitArray2buffer(witness.slice(1, 257)).toString("hex"));
    // const arrOut = witness.slice(1, 257);
    // const hash2 = bitArray2buffer(arrOut).toString("hex");
    // console.log(hash);
    // console.log(hash2);
}
main()
    .then(() => { })
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });