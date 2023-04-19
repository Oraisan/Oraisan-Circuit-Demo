// npm i @cosmjs/encoding
const { fromBase64, toBech32 } = require('@cosmjs/encoding')
// npm i @cosmjs/crypto
const { sha256 } = require('@cosmjs/crypto')

let prefix = "oraivalcons"

// Chain Format: 
// {
//    "@type":"/cosmos.crypto.ed25519.PubKey",
//    "key":"/O7BtNW0pafwfvomgR4ZnfldwPXiFfJs9mHg3gwfv5Q="
// }

// we just need the .key string from the object
let pubKey = "/ShOMJ4joYZBqPVFtD0+skU59lBh84uAyLkmeL6Dpwo="
const addr = toBech32(prefix, sha256(fromBase64(pubKey)).slice(0, 20))
console.log(fromBase64(pubKey))
console.log(sha256(fromBase64(pubKey)).slice(0, 20))
console.log(addr)