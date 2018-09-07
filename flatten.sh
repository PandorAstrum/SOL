
#!/usr/bin/env bash

rm -rf flats/*
./node_modules/.bin/truffle-flattener contracts/TrainDanyToken.sol > flats/TrainDanyToken_flat.sol
./node_modules/.bin/truffle-flattener contracts/TrainDanyPresale.sol > flats/TrainDanyPresale_flat.sol
./node_modules/.bin/truffle-flattener contracts/TrainDanyPrivatesale.sol > flats/TrainDanyPrivatesale_flat.sol
./node_modules/.bin/truffle-flattener contracts/TrainDanyCrowdsale.sol > flats/TrainDanyCrowdsale_flat.sol