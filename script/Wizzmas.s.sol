// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/WizzmasArtwork.sol";
import "../src/WizzmasArtworkMinter.sol";
import "../src/WizzmasCard.sol";

contract WizzmasScript is Script {
    function run() external {
        uint256 numArtworkTypes = 3;
        string memory cardsBaseURI = vm.envString("BASE_URI_CARDS");
        string memory artworksBaseURI = vm.envString("BASE_URI_ARTWORKS");
        address wizardsAddress = vm.envAddress("CONTRACT_ADDRESS_WIZARDS");
        address soulsAddress = vm.envAddress("CONTRACT_ADDRESS_SOULS");
        address warriorsAddress = vm.envAddress("CONTRACT_ADDRESS_WARRIORS");
        address poniesAddress = vm.envAddress("CONTRACT_ADDRESS_PONIES");

        vm.startBroadcast();
        WizzmasArtwork artwork = new WizzmasArtwork();
        artwork.setTokenURI(0, string.concat(artworksBaseURI, "0"));
        artwork.setTokenURI(1, string.concat(artworksBaseURI, "1"));
        artwork.setTokenURI(2, string.concat(artworksBaseURI, "2"));
        WizzmasArtworkMinter artworkMinter = new WizzmasArtworkMinter(
            address(artwork),
            numArtworkTypes
        );
        artwork.addMinter(address(artworkMinter));
        WizzmasCard card = new WizzmasCard(
            address(artwork),
            wizardsAddress,
            soulsAddress,
            warriorsAddress,
            poniesAddress,
            cardsBaseURI
        );
        vm.stopBroadcast();
    }
}
