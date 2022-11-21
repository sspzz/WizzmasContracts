//
// Wizzmas
//
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract WizzmasCard is
    ERC721,
    ERC721Enumerable,
    ERC721Burnable,
    Ownable,
    ReentrancyGuard
{
    address public artworkAddress;

    string public baseURI;

    bool public mintEnabled = false;

    event WizzmasCardMinted(
        address tokenContract,
        uint256 tokenId,
        uint256 artworkType,
        address sender,
        address recipient
    );

    constructor(address _wizzmasArtworkAddress, string memory _initialBaseURI)
        ERC721("WizzmasCard", "WizzmasCard")
    {
        artworkAddress = _wizzmasArtworkAddress;
        setBaseURI(_initialBaseURI);
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }

    // You must own a wizard to perform the spell
    function mint(
        address _tokenContract,
        uint256 _tokenId,
        uint256 _artworkId,
        address recipient
    ) public nonReentrant {
        require(mintEnabled, "MINT_CLOSED");
        require(msg.sender != recipient, "CANNOT_SEND_TO_SELF");
        require(
            IERC721(_tokenContract).ownerOf(_tokenId) == _msgSender(),
            "NOT_OWNER"
        );
        require(
            IERC1155(artworkAddress).balanceOf(_msgSender(), _artworkId) > 0,
            "NO_ARTWORK"
        );

        // Burn the Artwork?
        // ERC1155Burnable(artworkAddress).burn(
        //     _msgSender(),
        //     _artworkId,
        //     1
        // );

        // Mint the Card
        uint256 newId = totalSupply();
        _safeMint(recipient, newId);

        emit WizzmasCardMinted(
            _tokenContract,
            _tokenId,
            _artworkId,
            msg.sender,
            recipient
        );
    }

    function tokensOfOwner(address _owner)
        external
        view
        returns (uint256[] memory)
    {
        uint256 tokenCount = balanceOf(_owner);
        if (tokenCount == 0) {
            return new uint256[](0);
        } else {
            uint256[] memory result = new uint256[](tokenCount);
            uint256 index;
            for (index = 0; index < tokenCount; index++) {
                result[index] = tokenOfOwnerByIndex(_owner, index);
            }
            return result;
        }
    }

    function withdraw() public onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId,
        uint256 batchSize
    ) internal override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    // Only contract owner shall pass
    function setBaseURI(string memory _newBaseURI) public onlyOwner {
        baseURI = _newBaseURI;
    }

    function setMintEnabled(bool _newMintEnabled) public onlyOwner {
        mintEnabled = _newMintEnabled;
    }

    function setArtworkAddress(address _address) public onlyOwner {
        artworkAddress = _address;
    }
}
