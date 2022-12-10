// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "openzeppelin-contracts/utils/Strings.sol";
import "../../src/WizzmasArtwork.sol";
import "../../src/WizzmasArtworkMinter.sol";
import "../../src/WizzmasCard.sol";

contract WizzmasScript is Script {
    function run() external {
        vm.startBroadcast();

        // Artworks
        uint256 numArtworkTypes = 1;
        WizzmasArtwork artwork = new WizzmasArtwork();
        for (uint i = 0; i < numArtworkTypes; i++) {
            artwork.setTokenURI(
                i,
                string.concat(
                    vm.envString("BASE_URI_ARTWORKS"),
                    Strings.toString(i)
                )
            );
        }

        // Artworks Minter
        WizzmasArtworkMinter artworkMinter = new WizzmasArtworkMinter(
            address(artwork),
            numArtworkTypes
        );
        artwork.addMinter(address(artworkMinter));

        // Cards
        WizzmasCard card = new WizzmasCard(
            address(artwork),
            vm.envAddress("CONTRACT_ADDRESS_WIZARDS"),
            vm.envAddress("CONTRACT_ADDRESS_SOULS"),
            vm.envAddress("CONTRACT_ADDRESS_WARRIORS"),
            vm.envAddress("CONTRACT_ADDRESS_PONIES"),
            vm.envAddress("CONTRACT_ADDRESS_BEASTS"),
            vm.envAddress("CONTRACT_ADDRESS_SPAWN"),
            vm.envString("BASE_URI_CARDS")
        );

        vm.stopBroadcast();
    }
}
