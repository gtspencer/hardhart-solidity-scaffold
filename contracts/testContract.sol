// SPDX-License-Identifier: MIT

/// @title Mecole
/// @author The NFT Project

pragma solidity ^0.8.0;

import "erc721a/contracts/ERC721A.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract TestContract is ERC721A, Ownable, ReentrancyGuard {
    using Strings for uint256;
    string public uri = "https://nft.retrodoges.com/main/";

    constructor() ERC721A("RD", "RetroDoges") {
    }

    function mint() external payable nonReentrant {
        _mint(_msgSender(), 1);
    }

    function mintNumTo(uint256 num, address to) external payable nonReentrant {
        _mint(to, num);
    }

    function tokenURI(uint256 tokenId)
    public
    view
    virtual
    override
    returns (string memory)
    {
        require(_exists(tokenId), "Nonexistent token");

        return string(abi.encodePacked(uri, tokenId.toString()));
    }

    // ------- Overrides --------
    function _startTokenId() internal view override returns (uint256) {
        return 1;
    }
}