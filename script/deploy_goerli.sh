#!/usr/bin/env bash

if [ -f .env ]
then
  export $(cat .env | xargs) 
else
    echo "Please set your .env file"
    exit 1
fi

forge script ./script/foundry/Wizzmas.s.sol:WizzmasScript \
    --rpc-url ${GOERLI_RPC_URL} \
    --private-key ${GOERLI_PRIVATE_KEY}