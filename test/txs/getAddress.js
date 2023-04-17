const { Secp256k1, Secp256k1Signature, Ed25519 } = require("@cosmjs/crypto");
const crypto = require("crypto");
const { getAddressFromPublicKey } = require("cosmos-wallet");
const hash = crypto.createHash("sha256");

const txs = {
  txs: [
    {
      body: {
        messages: [
          {
            "@type": "/cosmwasm.wasm.v1.MsgExecuteContract",
            sender: "orai17xuym0peprjanerrcjlfp0mh73zlmxw9eaxfuf",
            contract: "orai1m6q5k5nr2eh8q0rdrf57wr7phk7uvlpg7mwfv5",
            msg: {
              provide_liquidity: {
                assets: [
                  {
                    info: {
                      token: {
                        contract_addr:
                          "orai1lus0f0rhx8s03gdllx2n6vhkmf0536dv57wfge",
                      },
                    },
                    amount: "2455042",
                  },
                  {
                    info: {
                      native_token: {
                        denom: "orai",
                      },
                    },
                    amount: "5780",
                  },
                ],
              },
            },
            funds: [
              {
                denom: "orai",
                amount: "5780",
              },
            ],
          },
        ],
        memo: "",
        timeout_height: "0",
        extension_options: [],
        non_critical_extension_options: [],
      },
      auth_info: {
        signer_infos: [
          {
            public_key: {
              "@type": "/cosmos.crypto.secp256k1.PubKey",
              key: "AhIhPEdG+BOc/1UIc5/aROpypH0kAiaDJZdiCKPIykoY",
            },
            mode_info: {
              single: {
                mode: "SIGN_MODE_DIRECT",
              },
            },
            sequence: "954",
          },
        ],
        fee: {
          amount: [
            {
              denom: "orai",
              amount: "1615",
            },
          ],
          gas_limit: "538327",
          payer: "",
          granter: "",
        },
      },
      signatures: [
        "ibKp2DM/qdczdVX2Bti74nSY5E5MoI98j15PN8OzET0wEy+1dt3PIK+qO37CaHpjAo+udQYxp18TO26jSY8JRw==",
      ],
    },
    {
      body: {
        messages: [
          {
            "@type": "/cosmwasm.wasm.v1.MsgExecuteContract",
            sender: "orai1senr0e9zfl4mwpxahayuvucaacmq2qy9dmj4lm",
            contract: "orai10ldgzued6zjp0mkqwsv2mux3ml50l97c74x8sg",
            msg: {
              send: {
                amount: "140999000000",
                contract: "orai14wy8xndhnvjmx6zl2866xqvs7fqwv2arhhrqq9",
                msg: "eyJjb252ZXJ0X3JldmVyc2UiOnsiZnJvbSI6eyJuYXRpdmVfdG9rZW4iOnsiZGVub20iOiJpYmMvQzQ1OEI0Q0M0RjU1ODEzODhCOUFDQjQwNzc0RkRGQkNFREM3N0E3RjdDREZCMTEyQjQ2OTc5NEFGODZDNEE2OSJ9fX19",
              },
            },
            funds: [],
          },
          {
            "@type": "/ibc.applications.transfer.v1.MsgTransfer",
            source_port: "transfer",
            source_channel: "channel-20",
            token: {
              denom:
                "ibc/C458B4CC4F5581388B9ACB40774FDFBCEDC77A7F7CDFB112B469794AF86C4A69",
              amount: "140999000000000000000000",
            },
            sender: "orai1senr0e9zfl4mwpxahayuvucaacmq2qy9dmj4lm",
            receiver: "oraib1senr0e9zfl4mwpxahayuvucaacmq2qy966kewc",
            timeout_height: {
              revision_number: "0",
              revision_height: "0",
            },
            timeout_timestamp: "1679046560980000000",
            memo: "oraib0x74C82129b3CD10d4cEF507fd137fF8429C65DD7c",
          },
        ],
        memo: "",
        timeout_height: "0",
        extension_options: [],
        non_critical_extension_options: [],
      },
      auth_info: {
        signer_infos: [
          {
            public_key: {
              "@type": "/cosmos.crypto.secp256k1.PubKey",
              key: "A6q7GJI22D4RBBA3Tg1QNEGRx9/B3Zo2b9iLsrmIaZ4D",
            },
            mode_info: {
              single: {
                mode: "SIGN_MODE_DIRECT",
              },
            },
            sequence: "15938",
          },
        ],
        fee: {
          amount: [
            {
              denom: "orai",
              amount: "5001",
            },
          ],
          gas_limit: "2000000",
          payer: "",
          granter: "",
        },
      },
      signatures: [
        "bGnGdb7lQxAVPY5VQnDVkJvGvy277zI8TRvqI0jlH4xc82AArPgDPuuCfviOt/9oVCm5H91d6ynDUrNJDiX6qQ==",
      ],
    },
  ],
};

const sum = {
  account_number: "11090",
  chain_id: "Oraichain",
  fee: {
    amount: [
      {
        amount: "1615",
        denom: "orai",
      },
    ],
    gas_limit: "538327",
  },
  memo: "",
  msgs: [
    {
      "@type": "/cosmwasm.wasm.v1.MsgExecuteContract",
      sender: "orai17xuym0peprjanerrcjlfp0mh73zlmxw9eaxfuf",
      contract: "orai1m6q5k5nr2eh8q0rdrf57wr7phk7uvlpg7mwfv5",
      msg: {
        provide_liquidity: {
          assets: [
            {
              info: {
                token: {
                  contract_addr: "orai1lus0f0rhx8s03gdllx2n6vhkmf0536dv57wfge",
                },
              },
              amount: "2455042",
            },
            {
              info: {
                native_token: {
                  denom: "orai",
                },
              },
              amount: "5780",
            },
          ],
        },
      },
      funds: [
        {
          denom: "orai",
          amount: "5780",
        },
      ],
    },
  ],
  sequence: "954",
};

// const verifySignatureCosms = () => {
//   let tx = JSON.stringify(sum);

//   let messageHash = Buffer.from(hash.update(tx).digest());

//   let signature = Buffer.from(txs.txs[0].signatures[0], "base64");

//   let publicKey = Buffer.from(
//     txs.txs[0].auth_info.signer_infos[0].public_key.key,
//     "base64"
//   );

//   let verify = Secp256k1.verifySignature(signature, messageHash, publicKey);
//   console.log(verify);
// };

// verifySignatureCosms();

// get address from publickey oraichain
function getAddres(pubkey) {
  const pubkeyBytes = Buffer.from(pubkey, "base64");
  console.log(pubkeyBytes)
  return getAddressFromPublicKey(pubkeyBytes, "orai");
}

const address = getAddres("AhIhPEdG+BOc/1UIc5/aROpypH0kAiaDJZdiCKPIykoY");
console.log(address);