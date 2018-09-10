
#!/usr/bin/env bash

rm -rf flats/*
./node_modules/.bin/truffle-flattener contracts/TrainDanyToken.sol > flats/TrainDanyToken_flat.sol
./node_modules/.bin/truffle-flattener contracts/TrainDanyCrowdsale.sol > flats/TrainDanyCrowdsale_flat.sol