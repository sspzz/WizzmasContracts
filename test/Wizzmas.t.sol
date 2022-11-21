// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/WizzmasArtwork.sol";
import "../src/WizzmasArtworkMinter.sol";
import "../src/WizzmasCard.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

// Fake Wizards contract for testing
contract DummyERC721 is ERC721 {
    constructor() ERC721("Dummy", "Dummy") {}

    uint256 counter = 0;

    function mint() public {
        _safeMint(msg.sender, counter++);
    }
}

contract WizzmasTest is Test {
    DummyERC721 public wizards;
    DummyERC721 public souls;
    DummyERC721 public warriors;
    DummyERC721 public ponies;

    WizzmasArtwork public artwork;
    WizzmasArtworkMinter public artworkMinter;
    WizzmasCard public card;

    address owner;
    address ZERO_ADDRESS = address(0);
    address spz = address(1);
    address jro = address(2);

    function setUp() public {
        owner = address(this);

        wizards = new DummyERC721();
        souls = new DummyERC721();
        warriors = new DummyERC721();
        ponies = new DummyERC721();

        artwork = new WizzmasArtwork();
        artworkMinter = new WizzmasArtworkMinter(address(artwork));
        artwork.addMinter(address(artworkMinter));
        card = new WizzmasCard(
            address(artwork),
            address(wizards),
            address(souls),
            address(warriors),
            address(ponies),
            "fakeURI"
        );
    }

    function testInitialState() public {
        // TODO: test states across the board
        assertEq(card.baseURI(), "fakeURI");
    }

    function testMintArtwork() public {
        artworkMinter.setMintEnabled(true);
        vm.startPrank(spz);
        artworkMinter.mint(0);
        artworkMinter.mint(1);
        artworkMinter.mint(2);
        vm.stopPrank();
    }

    function testMintInvalidArtwork() public {
        artworkMinter.setMintEnabled(true);
        vm.expectRevert(bytes("INCORRECT_ARTWORK_TYPE"));
        vm.prank(spz);
        artworkMinter.mint(3);
    }

    function testMintCard() public {
        artworkMinter.setMintEnabled(true);
        card.setMintEnabled(true);

        vm.startPrank(spz);
        artworkMinter.mint(0);
        wizards.mint();
        card.mint(address(wizards), 0, 0, jro);
        vm.stopPrank();
    }

    function testMintAllCardTypes() public {
        artworkMinter.setMintEnabled(true);
        card.setMintEnabled(true);

        vm.startPrank(spz);
        artworkMinter.mint(0);
        wizards.mint();
        souls.mint();
        warriors.mint();
        ponies.mint();
        card.mint(address(wizards), 0, 0, jro);
        card.mint(address(souls), 0, 0, jro);
        card.mint(address(warriors), 0, 0, jro);
        card.mint(address(ponies), 0, 0, jro);
        vm.stopPrank();
    }


    function testMintCardWithUnsupportedNFT() public {
        artworkMinter.setMintEnabled(true);
        card.setMintEnabled(true);

        vm.startPrank(spz);
        artworkMinter.mint(0);
        DummyERC721 unsupp = new DummyERC721();
        unsupp.mint();
        vm.expectRevert(bytes("UNSUPPORTED_TOKEN"));
        card.mint(address(unsupp), 0, 0, jro);
        vm.stopPrank();
    }

    function testMintCardWithUnownedNFT() public {
        artworkMinter.setMintEnabled(true);
        card.setMintEnabled(true);

        vm.prank(jro);
        wizards.mint();
        vm.startPrank(spz);
        artworkMinter.mint(0);
        vm.expectRevert(bytes("NOT_OWNER"));
        card.mint(address(wizards), 0, 0, jro);
        vm.stopPrank();
    }

    function testMintCardWithoutArtwork() public {
        artworkMinter.setMintEnabled(true);
        card.setMintEnabled(true);

        vm.startPrank(spz);
        wizards.mint();
        vm.expectRevert(bytes("NO_ARTWORK"));
        card.mint(address(wizards), 0, 0, jro);
        vm.stopPrank();
    }

    function testMintCardSendingToSelf() public {
        artworkMinter.setMintEnabled(true);
        card.setMintEnabled(true);

        vm.startPrank(spz);
        wizards.mint();
        artworkMinter.mint(0);
        vm.expectRevert(bytes("SEND_TO_SELF"));
        card.mint(address(wizards), 0, 0, spz);
        vm.stopPrank();
    }

}
