// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/WizzmasArtwork.sol";
import "../src/WizzmasArtworkMinter.sol";
import "../src/WizzmasCard.sol";

contract WizzmasTest is Test {    
    WizzmasArtwork public artwork;
    WizzmasArtworkMinter public artworkMinter;
    WizzmasCard public card;

    address owner;
    address ZERO_ADDRESS = address(0);
    address spz = address(1);
    address jro = address(2);

    function setUp() public {
        owner = address(this);        
        artwork = new WizzmasArtwork();
        artworkMinter = new WizzmasArtworkMinter(address(artwork));
        artwork.addMinter(address(artworkMinter));
        card = new WizzmasCard(address(artwork), "fakeURI");
    }

    function testInitialState() public {
        assertEq(card.baseURI(), "fakeURI");
    }

    function testMintArtwork() public {
        artworkMinter.setMintEnabled(true);
        vm.prank(spz);
        artworkMinter.mint(0);
    }
}