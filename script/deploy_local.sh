forge script ./script/foundry/Wizzmas.s.sol:WizzmasScript --fork-url http://localhost:8545 --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 --broadcast
cast send 0x707531c9999AaeF9232C8FEfBA31FBa4cB78d84a "setMintEnabled(bool)" "true" --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
cast send 0x24432a08869578aAf4d1eadA12e1e78f171b1a2b "setMintEnabled(bool)" true --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 
