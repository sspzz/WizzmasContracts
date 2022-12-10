// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {Owned} from "solmate/auth/Owned.sol";

interface WizzCover {
    function tokenSupply(uint256 tokenId) external returns (uint256);

    function mint(
        address initialOwner,
        uint256 tokenId,
        uint256 amount,
        bytes calldata data
    ) external;
}

interface Card {
    function mint(
        uint256 coverId,
        address[] tokenContract,
        uint256[] tokenId,
        uint256[] templateId,
        string[] message,
        address[] recipient,
        uint256 numToMint
    ) external;
}

contract WizzmasMinter is Owned {
    address public wizzCoverAddress;
    uint256 public totalCovers;
    struct CardSale {
        bool mintEnabled;
        uint256 price;
        uint256 coverId;
        //num of free claims?
    }

    struct CoverSale {
        bool mintEnabled;
        uint256 price;
        // totalSupply
        // num of free claims?
    }

    mapping(address => CardSale) public cardSales;
    mapping(uint256 => CoverSale) public coverSales;

    // events

    constructor(address _owner, address _coverAddy) {
        wizzCoversAddress = _coverAddy;
        owner = _owner;
    }

    function mintCover(uint256 id) public payable {
        CoverSale coverSale = coverSales[id];
        require(coverSale.mintEnabled, "Mint For Cover Closed");
        require(msg.value == coverSale.price, "Incorrect ETH amount for mint");
        
        WizzCover cover = WizzCover(wizzCoverAddress);
        cover.mint(msg.sender, id, 1, "");
    }
    
    // batch mints per cover used
    function mintCard(
        address cardAddress,
        uint256 coverId,
        address[] tokenContracts,
        uint256[] tokenIds,
        uint256[] templateId,
        string[] messages,
        address[] recipients,
        uint256 numToMint
    ) public payable {
        CardSale cardSale = cardSales[cardAddress];
        require(cardSale.mintEnabled, "Mint For Card Set Closed");
        require(msg.value == coverSale.price * numToMint, "Incorrect ETH amount for mints");

        Card card = Card(cardAddress);
        card.mint(coverId, tokenContracts, tokenIds, templateIds, messages, recipients, numToMint);
    }

    function addCardSale(address cardAddress, uint256 _price) public {
        cardSales[cardAddress].mintEnabled = false;
        cardSales[cardAddress].price = _price;
    }

    function enableCardMint(address cardAddress, bool _mintEnabled) public {
        cardSales[cardAddress].mintEnabled = _mintEnabled;
    }

    function updateCardSale(address cardAddress, uint256 _price) public {
        // check if mintEnabled before doing operations
        require(!cardSales[cardAddress].mintEnabled, "Mint currently enabled");
        cardSales[cardAddress].price = _price;
    }
}