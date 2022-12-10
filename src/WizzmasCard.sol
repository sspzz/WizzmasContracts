//
// WizzmasCard
//
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract WizzmasCard is ERC721, ERC721Burnable, Ownable, ReentrancyGuard {
    struct Card {
        uint256 card;
        address tokenContract;
        uint256 token;
        uint256 artwork;
        uint256 template;
        string message;
        address sender;
        address recipient;
    }
    mapping(uint256 => Card) cards;
    event WizzmasCardMinted(Card data);
    uint256 public numTemplates = 0;

    using Counters for Counters.Counter;
    Counters.Counter private nextTokenId;

    address public artworkAddress;

    address public wizardsAddress;
    address public soulsAddress;
    address public warriorsAddress;
    address public poniesAddress;
    address public beastsAddress;
    address public spawnAddress;
    address[] internal contracts;

    string public baseURI;

    bool public mintEnabled = false;

    string[] public messages = [
        "Have a very Merry Wizzmas!",
        "May your Holidays be full of !magic",
        "HoHoHo! Merry Wizzmas!",
        "Happy Holidays! Eat plenty of Jelly Donuts!"
    ];
    
    mapping(address => uint256[]) senderCards; 
    mapping(address => uint256[]) recipientCards;

    constructor(
        address _artworkAddress,
        address _wizardsAddres,
        address _soulsAddress,
        address _warriorsAddress,
        address _poniesAddress,
        address _beastsAddress,
        address _spawnAddress,
        uint256 _numTemplates,
        string memory _initialBaseURI
    ) ERC721("WizzmasCard", "WizzmasCard") {
        artworkAddress = _artworkAddress;
        wizardsAddress = _wizardsAddres;
        soulsAddress = _soulsAddress;
        warriorsAddress = _warriorsAddress;
        poniesAddress = _poniesAddress;
        beastsAddress = _beastsAddress;
        spawnAddress = _spawnAddress;
        contracts = [
            wizardsAddress,
            soulsAddress,
            warriorsAddress,
            poniesAddress,
            beastsAddress,
            spawnAddress
        ];
        setNumTemplates(_numTemplates);
        setBaseURI(_initialBaseURI);
    }

    function mint(
        address _tokenContract,
        uint256 _tokenId,
        uint256 _artworkId,
        uint256 _templateId,
        uint256 _messageId,
        address _recipient
    ) public nonReentrant {
        require(mintEnabled, "MINT_CLOSED");
        require(_messageId < messages.length, "INVALID_MESSAGE");
        require(_templateId < numTemplates, "INVALID_TEMPLATE");
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

        uint256 newId = nextTokenId.current();
        _safeMint(_recipient, newId);
        nextTokenId.increment();

        cards[newId] = Card(
            newId,
            _tokenContract,
            _tokenId,
            _artworkId,
            _templateId,
            messages[_messageId],
            _msgSender(),
            _recipient
        );

        senderCards[msg.sender].push(newId);
        recipientCards[_recipient].push(newId);
        emit WizzmasCardMinted(cards[newId]);
    }

    function getCard(uint256 cardId) public view returns (Card memory) {
        if (nextTokenId.current() > cardId) {
            return cards[cardId];
        }
        revert("CARD_NOT_MINTED");
    }

    function getRecipientCardIds(address recipient) public view returns (uint256[] memory){
        return recipientCards[recipient];
    }

    function getSenderCardIds(address sender) public view returns (uint256[] memory) {
        return senderCards[sender];
    }

    function availableMessages() public view returns (string[] memory) {
        return messages;
    }

    function supportedContracts() public view returns (address[] memory) {
        return contracts;
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }

    // Only contract owner shall pass
    function withdraw() public onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }

    function setNumTemplates(uint256 _numTemplates) public onlyOwner {
        numTemplates = _numTemplates;
    }

    function addMessage(string memory _message) public onlyOwner {
        messages.push(_message);
    }

    function addMessages(string[] memory _messages) public onlyOwner {
        for (uint i = 0; i < _messages.length; i++) {
            messages.push(_messages[i]);
        }
    }

    function removeMessage(uint index) public onlyOwner {
        require(index < messages.length, "INDEX_OUT_OF_BOUNDS");
        for (uint i = index; i < messages.length - 1; i++) {
            messages[i] = messages[i + 1];
        }
        messages.pop();
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
