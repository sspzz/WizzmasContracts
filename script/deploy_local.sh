#!/usr/bin/env bash

PKEY=0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80

forge script ./script/foundry/Wizzmas.s.sol:WizzmasScript \
    --broadcast \
    --fork-url http://localhost:8545 \
    --private-key $PKEY

cast send 0x24432a08869578aAf4d1eadA12e1e78f171b1a2b \
    "setMintEnabled(bool)" true \
    --private-key $PKEY

cast send 0xbf2ad38fd09F37f50f723E35dd84EEa1C282c5C9 \
    "setMintEnabled(bool)" true \
    --private-key $PKEY 
