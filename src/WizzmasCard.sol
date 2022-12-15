//
// WizzmasCard
//
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "solmate/tokens/ERC721.sol";
import "solmate/tokens/ERC1155.sol";
import {LibString} from "solmate/utils/LibString.sol";
import "solmate/utils/ReentrancyGuard.sol";
import "solmate/auth/Owned.sol";

contract WizzmasCard is ERC721, Owned, ReentrancyGuard {
    using LibString for uint256;

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

    uint256 private nextTokenId = 0;

    address public artworkAddress;

    mapping(address => bool) public supportedTokenContracts;

    string public baseURI;

    bool public mintEnabled = false;
    
    mapping(address => uint256[]) public senderCards; 
    mapping(address => uint256[]) public recipientCards;

    constructor(
        address _artworkAddress,
        address[] memory _tokenContracts,
        uint256 _numTemplates,
        string memory _initialBaseURI
    ) ERC721("WizzmasCard", "WizzmasCard") Owned(msg.sender) {
        artworkAddress = _artworkAddress;
        for(uint8 i = 0; i < _tokenContracts.length; i++) {
            supportedTokenContracts[_tokenContracts[i]] = true;
        }
        numTemplates = _numTemplates;
        setBaseURI(_initialBaseURI);
    }

    function mint(
        address _tokenContract,
        uint256 _tokenId,
        uint256 _artworkId,
        uint256 _templateId,
        string memory _message,
        address _recipient
    ) public nonReentrant {
        require(mintEnabled, "MINT_CLOSED");
        require(_templateId < numTemplates, "INVALID_TEMPLATE");
        require(supportedTokenContracts[_tokenContract] == true, "Unsupported token contract for mint");
        require(bytes(_message).length < 64, "Message too long"); // keep bytes length of message under 64 to take up 3 slots in storage and 2 slots in memory
        
        require(
            ERC721(_tokenContract).ownerOf(_tokenId) == msg.sender,
            "NOT_OWNER"
        );
        require(
            ERC1155(artworkAddress).balanceOf(msg.sender, _artworkId) > 0,
            "NO_ARTWORK"
        );

        uint256 newId = nextTokenId;
        _safeMint(_recipient, newId);
        ++nextTokenId;

        cards[newId] = Card(
            newId,
            _tokenContract,
            _tokenId,
            _artworkId,
            _templateId,
            _message,
            msg.sender,
            _recipient
        );

        senderCards[msg.sender].push(newId);
        recipientCards[_recipient].push(newId);
        emit WizzmasCardMinted(cards[newId]);
    }

    function getCard(uint256 cardId) public view returns (Card memory) {
        if (nextTokenId > cardId) {
            return cards[cardId];
        }
        revert("CARD_NOT_MINTED");
    }

    function tokenURI(uint256 id) public view virtual override returns (string memory) {
        return string.concat(baseURI, id.toString());
    }

    function getRecipientCardIds(address recipient) public view returns (uint256[] memory){
        return recipientCards[recipient];
    }

    function getSenderCardIds(address sender) public view returns (uint256[] memory) {
        return senderCards[sender];
    }

    function _baseURI() internal view virtual returns (string memory) {
        return baseURI;
    }

    // Only contract owner shall pass
    function withdraw() public onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }

    function setNumTemplates(uint256 _numTemplates) public onlyOwner {
        numTemplates = _numTemplates;
    }

    function strikeMessage(uint256 cardId) public onlyOwner {
        require(cardId < nextTokenId, "Card not minted yet");
        cards[cardId].message = 'Sender has a dirty kobold mouth xD';
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

    function setSupportedTokenContract(address _address, bool supported) public onlyOwner {
        supportedTokenContracts[_address] = supported;
    }
}
