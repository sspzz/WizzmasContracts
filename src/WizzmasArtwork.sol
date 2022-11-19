// SPDX-License-Identifier: MIT
//
// WizzmasArtwork
//
pragma solidity ^0.8.15;

import "solmate/tokens/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract WizzmasArtwork is ERC1155, Ownable {
    mapping(uint256 => string) public tokenURIs;
    mapping(uint256 => uint256) public tokenSupply;
    mapping(address => bool) public minters;

    modifier onlyMinterOrOwner() {
        require(
            minters[msg.sender] || msg.sender == owner(),
            "only minter or owner can call this function"
        );
        _;
    }

    constructor() ERC1155() {}

    function uri(uint256 id) public view override returns (string memory) {
        require(bytes(tokenURIs[id]).length > 0, "MISSING_TOKEN");
        return tokenURIs[id];
    }

    function addMinter(address minter) public onlyOwner {
        minters[minter] = true;
    }

    function mint(
        address initialOwner,
        uint256 tokenId,
        uint256 amount,
        bytes calldata data
    ) public onlyMinterOrOwner {
        require(amount > 0, "INVALID_AMOUNT");
        tokenSupply[tokenId] = tokenSupply[tokenId] + amount;
        _mint(initialOwner, tokenId, amount, data);
    }

    function setTokenURI(uint256 tokenId, string calldata tokenUri)
        public
        onlyOwner
    {
        emit URI(tokenUri, tokenId);
        tokenURIs[tokenId] = tokenUri;
    }
}