const { marshalTx, unmarshalTx } = require('@tendermint/amino-js');



const main = async () => {
    const tx = {
        "body": {
            "messages": [
                {
                    "@type": "/cosmwasm.wasm.v1.MsgExecuteContract",
                    "sender": "orai1z44dgrextunnru8magxzlc5h2h9lyqnmymrd3e",
                    "contract": "orai19aczly33fr3s23030qeu0dexyu8vcrwwdpva9v",
                    "msg": {
                        "request": {
                            "threshold": 2,
                            "service": "orchai_price",
                            "preference_executor_fee": {
                                "denom": "orai",
                                "amount": "0"
                            }
                        }
                    },
                    "funds": []
                }
            ],
            "memo": "",
            "timeout_height": "0",
            "extension_options": [],
            "non_critical_extension_options": []
        },
        "auth_info": {
            "signer_infos": [
                {
                    "public_key": {
                        "@type": "/cosmos.crypto.secp256k1.PubKey",
                        "key": "AlD+qYPdJqTDbZSD79eL4KDaDvPq8TcrrauIVJuKYqM+"
                    },
                    "mode_info": {
                        "single": {
                            "mode": "SIGN_MODE_DIRECT"
                        }
                    },
                    "sequence": "39960"
                }
            ],
            "fee": {
                "amount": [
                    {
                        "denom": "orai",
                        "amount": "0"
                    }
                ],
                "gas_limit": "689820",
                "payer": "",
                "granter": ""
            }
        },
        "signatures":
            "GXSmG1NkwCGtelkolS6AhNqbS/AhU1EnzXiu383ajT8MmBV9hzfqh26A9mVXkscJxcjPkSwVcqr0vJNt73Klvg=="

    };

    const encodedTx = marshalTx(tx);
    const decodedTx = unmarshalTx(encodedTx);
    console.log(encodedTx.toString("16"));
    console.log(decodedTx);
};

main()
    .then(() => { })
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });