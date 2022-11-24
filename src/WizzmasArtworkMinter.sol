//
// WizzmasCardMinter
//
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

interface ArtworkContract is IERC1155 {
    function tokenSupply(uint256 tokenId) external returns (uint256);

    function mint(
        address initialOwner,
        uint256 tokenId,
        uint256 amount,
        bytes calldata data
    ) external;
}

contract WizzmasArtworkMinter is Ownable, ReentrancyGuard {
    address public wizzmasArtworkAddress;
    uint256 public numArtworkTypes;

    bool public mintEnabled = false;
    uint256 public mintPrice = (1 ether * 0.01);
    uint256 public freeMintsPerAddress = 1;
    uint256 public constant MAX_SUPPLY = 1000;
    mapping(address => uint) public minted;
    mapping(uint256 => bool) public tokenFrozen;

    event WizzmasArtworkMinted(address minter, uint256 artworkType);
    event WizzmasArtworkClaimed(address claimer, uint256 artworkType);

    constructor(address _artworkAddress, uint256 _numArtworkTypes) {
        wizzmasArtworkAddress = _artworkAddress;
        numArtworkTypes = _numArtworkTypes;
    }

    function canClaim(address claimer) public view returns (bool) {
        return minted[claimer] < freeMintsPerAddress;
    }

    function claim(uint256 artworkType) public nonReentrant {
        require(mintEnabled, "MINT_CLOSED");
        require(!tokenFrozen[artworkType], "TOKEN_FROZEN");
        require(canClaim(_msgSender()), "FREE_CLAIMS_USED");
        ArtworkContract artwork = ArtworkContract(wizzmasArtworkAddress);
        require(artwork.tokenSupply(artworkType) + 1 <= MAX_SUPPLY, "SOLD_OUT");
        require(artworkType < numArtworkTypes, "INCORRECT_ARTWORK_TYPE");

        artwork.mint(msg.sender, artworkType, 1, "");

        minted[_msgSender()] += 1;

        emit WizzmasArtworkClaimed(_msgSender(), artworkType);
    }

    function mint(uint256 artworkType) public payable nonReentrant {
        require(mintEnabled, "MINT_CLOSED");
        require(!tokenFrozen[artworkType], "TOKEN_FROZEN");
        require(msg.value == mintPrice, "INCORRECT_ETH_VALUE");
        ArtworkContract artwork = ArtworkContract(wizzmasArtworkAddress);
        require(artwork.tokenSupply(artworkType) + 1 <= MAX_SUPPLY, "SOLD_OUT");
        require(artworkType < numArtworkTypes, "INCORRECT_ARTWORK_TYPE");

        artwork.mint(msg.sender, artworkType, 1, "");

        minted[_msgSender()] += 1;

        emit WizzmasArtworkMinted(_msgSender(), artworkType);
    }

    // Only contract owner shall pass
    function withdraw() public onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }

    function setMintEnabled(bool _newMintEnabled) public onlyOwner {
        mintEnabled = _newMintEnabled;
    }

    function setMintPrice(uint256 _newMintPrice) public onlyOwner {
        mintPrice = _newMintPrice;
    }

    function setFreeMintsPerAddress(uint256 _numMints) public onlyOwner {
        freeMintsPerAddress = _numMints;
    }

    function freezeToken(uint256 _tokenId) public onlyOwner {
        tokenFrozen[_tokenId] = true;
    }

    function setNumArtworkTypes(uint256 _artworkTypeMax) public onlyOwner {
        numArtworkTypes = _artworkTypeMax;
    }
}
