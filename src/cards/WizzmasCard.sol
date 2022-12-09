// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {ERC721} from "solmate/tokens/ERC721.sol";
import {Owned} from "solmate/auth/Owned.sol";

contract WizzmasCard is ERC721, Owned {

    struct Card {
        //todo: think on the struct for the Card and what to fill with
        address tokenContract;
        uint256 cover;
        uint256 template;
        string message;
        address sender;
        address recipient;
    }


    mapping(uint256 => Card) cards;
    


}

