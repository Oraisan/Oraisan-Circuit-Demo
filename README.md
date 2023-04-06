# 
```
npm i
```

download powersOfTau28_hez_final_22.ptau from https://github.com/iden3/snarkjs or https://hermez.s3-eu-west-1.amazonaws.com/powersOfTau28_hez_final_22.ptau 

then create folder ptau (same level with folder src) and save this ptau file to folder.

```
cd src/block/signature
circom *.circom --r1cs --wasm
cd verifySignatures_js

node generate_witness.js ./*.wasm ../input.json ../witness.wtns
cd ..
snarkjs g16s *.r1cs ../../ptau/powersOfTau28_hez_final_22.ptau  circuit_final.zkey
snarkjs g16p circuit_final.zkey witness.wtns proof.json public.
snarkjs zkey export solidityverifier *.zkey verifier.sol
```
then deploy contract verifier.sol
