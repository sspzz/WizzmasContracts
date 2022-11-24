#!/usr/bin/env bash

PKEY=0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80

forge script ./script/foundry/Wizzmas.s.sol:WizzmasScript \
    --broadcast \
    --fork-url http://localhost:8545 \
    --private-key $PKEY

cast send 0x2538a10b7fFb1B78c890c870FC152b10be121f04 \
    "setMintEnabled(bool)" true \
    --private-key $PKEY

cast send 0xdB05A386810c809aD5a77422eb189D36c7f24402 \
    "setMintEnabled(bool)" true \
    --private-key $PKEY 
