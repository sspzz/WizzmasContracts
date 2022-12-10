// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {ERC721A} from "erc721a/ERC721A.sol";
import {Owned} from "solmate/auth/Owned.sol";

contract WizzmasCard is ERC721A, Owned {

    struct Card {
        uint256 card;
        address tokenContract;
        uint256 token;
        uint256 cover;
        uint256 template;
        string message;
        address sender;
        address recipient;
    }
    mapping(uint256 => Card) cards;
    mapping(address => uint256[]) senderCards; 
    mapping(address => uint256[]) recipientCards;
    
    event WizzmasCardMinted(Card data);

    string public baseURI;

    constructor(string memory _uri) ERC721A("WizzmasCard", "WIZZMAS") {
        setBaseURI(_uri);
    }

    function mint(
        uint256 _coverId,
        address[] _tokenContracts,
        uint256[] _tokenIds,
        uint256[] _templateIds,
        string[] _messages,
        address[] _recipients,
        uint256 numToMint
    ) public {
        // requires prob better to check these in minter
        uint256 startId = _nextTokenId();
        _safeMint(_recipient, numToMint);

        for (uint256 i = startId; i <= startId + numToMint; i++) {
            cards[newId] = Card(
                i,
                _tokenContracts[i],
                _tokenIds[i],
                _coverId,
                _templateIds[i],
                _messages[i],
                msg.sender,
                _recipients[i]
            );

            senderCards[msg.sender].push(i);
            recipientCards[_recipient].push(i);
            emit WizzmasCardMinted(cards[i]);
        }
    }

    function getCard(uint256 cardId) public view returns (Card memory) {
        if (_nextTokenId() > cardId) {
            return cards[cardId];
        }
        revert("CARD_NOT_MINTED");
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }

    // Only contract owner shall pass
    function withdraw() public onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }

    function setBaseURI(string memory _newBaseURI) public onlyOwner {
        baseURI = _newBaseURI;
    }
}

