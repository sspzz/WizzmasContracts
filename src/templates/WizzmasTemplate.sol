// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "periphery/Ownablearama.sol";
import {ERC1155} from "solmate/tokens/ERC1155.sol";
import {LibString} from "solmate/utils/LibString.sol";


contract WizzmasTemplate is ERC1155, Ownablearama {
    using LibString for uint256;

    mapping(uint256 => string) public tokenURIs;
    mapping(uint256 => bool) public minters;

    string public baseURI;

    modifier onlyMinterOrOwner() {
        require(
            minters[msg.sender] || msg.sender == owner(),
            "only minter or owner can call this function"
        );
        _;
    }

    constructor(string memory _uri) ERC1155(_uri) {}

    function mint(

    ) public onlyMinterOrOwner {
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data,
    } public onlyMinterOrOwner {
        _mint(to, id, amount, data);
    }

    function setTokenURI(uint256 _tokenId, string calldata _tokenURI)
        external
        onlyOwner
    {
        tokenURIs[_tokenId] = _tokenURI;
    }

    function setIsMinter(address _minter, bool _isMinter) external onlyOwner {
        minters[_minter] = _isMinter;
    }

    function setURI(string memory _uri) external onlyOwner {
        super._setURI(_uri);
    }

    function uri(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory) {
            string memory tokenURI = tokenURIs[tokenId];

            return
                bytes(tokenURI).length > 0
                    ? tokenURI
                    : string(
                        abi.encodePacked(
                            super.uri(tokenId),
                            tokenId.toString()
                        )
                    );
        }

    //todo: let's set totalSupply and logic to be able to adjust so that mints
    //      don't happen on accident / we'll increase supply when we add more templates?

    //todo: was thinking we'd want separate templates for separate drops, but think
    //      it's better now to have one template contract that holds all templates for each
    //      "season"

    //todo: wanna rework the URI logic to be like art gobblers with baseURI + tokenId

    /*//////////////////////////////////////////////////////////////
                                URI LOGIC
    //////////////////////////////////////////////////////////////*/
}