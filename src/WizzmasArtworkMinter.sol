//
// WizzmasCardMinter
//
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "solmate/tokens/ERC1155.sol";
import "./WizzmasArtwork.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract WizzmasArtworkMinter is Ownable, ReentrancyGuard {
    address public wizzmasArtworkAddress;
    uint256 public constant MAX_SUPPLY = 1000;    

    bool public mintEnabled = false;
    uint256 public mintPrice = (1 ether * 0.01);
    uint256 public freeMintsPerAddress = 1;
    mapping(address => uint) public minted;        

    uint256 public numArtworkTypes = 3;

    event WizzmasArtworkMinted(address minter);

    constructor(address _artworkAddress) {
        wizzmasArtworkAddress = _artworkAddress;
    }

    function mint(uint256 artworkType) public payable nonReentrant {
        WizzmasArtwork artwork = WizzmasArtwork(wizzmasArtworkAddress);
        require(artworkType < numArtworkTypes, "INCORRECT_ARTWORK_TYPE");
        require(mintEnabled, "MINT_CLOSED");
        require(artwork.tokenSupply(artworkType) + 1 <= MAX_SUPPLY, "SOLD_OUT");
        require(msg.value == mintPrice || minted[msg.sender] < freeMintsPerAddress, "INCORRECT_ETH_VALUE");

        artwork.mint(msg.sender, artworkType, 1, "");

        emit WizzmasArtworkMinted(msg.sender);
    }

    function withdraw() public onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }

    // Only contract owner shall pass
    function setMintEnabled(bool _newMintEnabled) public onlyOwner {
        mintEnabled = _newMintEnabled;
    }

    function setMintPrice(uint256 _newMintPrice) public onlyOwner {
        mintPrice = _newMintPrice;
    }

    function setArtworkTypeMax(uint256 _artworkTypeMax) public onlyOwner {
        numArtworkTypes = _artworkTypeMax;
    }
}
