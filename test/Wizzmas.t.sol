// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/WizzmasArtwork.sol";
import "../src/WizzmasArtworkMinter.sol";
import "../src/WizzmasCard.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

// Fake Wizards contract for testing
contract FakeWizards is ERC721 {
    constructor() ERC721("Wizards", "Wizards") {}
    uint256 counter = 0;
    function mint() public {
        _safeMint(msg.sender, counter++);
    }
}

contract WizzmasTest is Test {    
    FakeWizards public wizards;
    WizzmasArtwork public artwork;
    WizzmasArtworkMinter public artworkMinter;
    WizzmasCard public card;

    address owner;
    address ZERO_ADDRESS = address(0);
    address spz = address(1);
    address jro = address(2);

    function setUp() public {
        owner = address(this);

        wizards = new FakeWizards();

        artwork = new WizzmasArtwork();
        artworkMinter = new WizzmasArtworkMinter(address(artwork));
        artwork.addMinter(address(artworkMinter));
        card = new WizzmasCard(address(artwork), "fakeURI");
    }

    function testInitialState() public {
        // TODO: test states across the board
        assertEq(card.baseURI(), "fakeURI");
    }

    function testMintArtwork() public {
        // Enable minting
        artworkMinter.setMintEnabled(true);
        card.setMintEnabled(true);

        // Mint artwork of type 0
        vm.prank(spz);
        artworkMinter.mint(0);

        // Mint wizard with tokenid 0
        vm.prank(spz);
        wizards.mint();

        // Mint card using wizard and artwork, send to JiroOno <3 
        vm.prank(spz);
        card.mint(address(wizards), 0, 0, jro);
    }
}