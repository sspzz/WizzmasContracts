//
// WizzmasCard
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
    struct Card {
        address tokenContract;
        uint256 token;
        uint256 artwork;
        string message;
        address sender;
        address recipient;
    }
    event WizzmasCardMinted(Card data);

    address public artworkAddress;

    address public wizardsAddress;
    address public soulsAddress;
    address public warriorsAddress;
    address public poniesAddress;
    address public beastsAddress;
    address public spawnAddress;
    address[] internal contracts = [
        wizardsAddress,
        soulsAddress,
        warriorsAddress,
        poniesAddress,
        beastsAddress,
        spawnAddress
    ];

    string public baseURI;

    bool public mintEnabled = false;

    mapping(uint256 => Card) public cards;

    string[] public messages = [
        "Have a very Merry Wizzmas!",
        "May your Holidays be full of !magic",
        "HoHoHo! Merry Wizzmas!",
        "Happy Holidays! Eat plenty of Jelly Donuts!"
    ];

    constructor(
        address _artworkAddress,
        address _wizardsAddres,
        address _soulsAddress,
        address _warriorsAddress,
        address _poniesAddress,
        address _beastsAddress,
        address _spawnAddress,
        string memory _initialBaseURI
    ) ERC721("WizzmasCard", "WizzmasCard") {
        artworkAddress = _artworkAddress;
        wizardsAddress = _wizardsAddres;
        soulsAddress = _soulsAddress;
        warriorsAddress = _warriorsAddress;
        poniesAddress = _poniesAddress;
        beastsAddress = _beastsAddress;
        spawnAddress = _spawnAddress;
        setBaseURI(_initialBaseURI);
    }

    // You must own a wizard to perform the spell
    function mint(
        address _tokenContract,
        uint256 _tokenId,
        uint256 _artworkId,
        uint256 _messageId,
        address _recipient
    ) public nonReentrant {
        require(mintEnabled, "MINT_CLOSED");
        require(_messageId < messages.length, "INVALID_MESSAGE");
        require(_msgSender() != _recipient, "SEND_TO_SELF");
        require(
            _tokenContract == wizardsAddress ||
                _tokenContract == soulsAddress ||
                _tokenContract == warriorsAddress ||
                _tokenContract == poniesAddress ||
                _tokenContract == beastsAddress ||
                _tokenContract == spawnAddress,
            "UNSUPPORTED_TOKEN"
        );
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
        _safeMint(_recipient, newId);

        cards[newId] = Card(
            _tokenContract,
            _tokenId,
            _artworkId,
            messages[_messageId],
            _msgSender(),
            _recipient
        );
        emit WizzmasCardMinted(cards[newId]);
    }

    function availableMessages() public view returns (string[] memory) {
        return messages;
    }

    function supportedContracts() public view returns (address[]) {
        return contracts;
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
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
    function withdraw() public onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }

    function setBaseURI(string memory _newBaseURI) public onlyOwner {
        baseURI = _newBaseURI;
    }

    function setMintEnabled(bool _newMintEnabled) public onlyOwner {
        mintEnabled = _newMintEnabled;
    }

    function setArtworkAddress(address _address) public onlyOwner {
        artworkAddress = _address;
    }

    function setWizardsAddress(address _address) public onlyOwner {
        wizardsAddress = _address;
    }

    function setSoulsAddress(address _address) public onlyOwner {
        soulsAddress = _address;
    }

    function setWarriorsAddress(address _address) public onlyOwner {
        warriorsAddress = _address;
    }

    function setPoniesAddress(address _address) public onlyOwner {
        poniesAddress = _address;
    }

    function setBeastsAddress(address _address) public onlyOwner {
        beastsAddress = _address;
    }

    function setSpawnAddress(address _address) public onlyOwner {
        spawnAddress = _address;
    }
}
