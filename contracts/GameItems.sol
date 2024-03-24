// contracts/GameItems.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

import {ERC1155} from "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

contract GameItems is ERC1155 {
    string private _baseURI = "ipfs://bafybeicdwvru4rhggyxjoafbqjbobfabpy6d42en5jvywxucofgeqqk6hi/";
    uint256 public constant GOLD = 0;
    uint256 public constant SILVER = 1;
    uint256 public constant THORS_HAMMER = 2;
    uint256 public constant SWORD = 3;
    uint256 public constant SHIELD = 4;

    constructor() ERC1155("ipfs://bafybeicdwvru4rhggyxjoafbqjbobfabpy6d42en5jvywxucofgeqqk6hi/{id}.json") {
        _mint(msg.sender, GOLD, 10**18, "");
        _mint(msg.sender, SILVER, 10**27, "");
        _mint(msg.sender, THORS_HAMMER, 1, "");
        _mint(msg.sender, SWORD, 10**9, "");
        _mint(msg.sender, SHIELD, 10**9, "");
    }

    function baseURI() public view virtual returns (string memory)
    {
        return _baseURI;
    }

    function uri(uint256 id) public view override returns (string memory)
    {
        string memory base = baseURI();
        return bytes(base).length > 0 ? string(abi.encodePacked(base, "BloomSquadOG.json")) : ""; 
    }
}