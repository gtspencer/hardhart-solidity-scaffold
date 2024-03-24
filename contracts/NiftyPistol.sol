pragma solidity ^0.8.0;

import "erc721a/contracts/ERC721A.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";

contract ContentNFTs is ERC721A("RetroDoges", "RD"), Ownable {
    string private baseUri = "https://nft.retrodoges.com/main/";

    constructor () {
    }

    function mint(uint256 amount)
        external {
        _safeMint(msg.sender, amount);
    }

    function updateBaseUri(string memory newBaseUri) external onlyOwner {
        baseUri = newBaseUri;
    }

    function exists(uint256 tokenId) public view returns(bool) {
        return _exists(tokenId);
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "Token not minted");

        return string(abi.encodePacked(baseUri, _toString(tokenId)));
    }
}