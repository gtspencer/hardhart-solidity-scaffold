// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

// Author: TOYMAKERSⓒ
// Drop: #1
// Project: TIME CAPSULE
/*
*******************************************************************************
          |                   |                  |                     |
 _________|________________.=""_;=.______________|_____________________|_______
|                   |  ,-"_,=""     `"=.|                  |
|___________________|__"=._o`"-._        `"=.______________|___________________
          |                `"=._o`"=._      _`"=._                     |
 _________|_____________________:=._o "=._."_.-="'"=.__________________|_______
|                   |    __.--" , ; `"=._o." ,-"""-._ ".   |
|___________________|_._"  ,. .` ` `` ,  `"-._"-._   ". '__|___________________
          |           |o`"=._` , "` `; .". ,  "-._"-._; ;              |
 _________|___________| ;`-.o`"=._; ." ` '`."\` . "-._ /_______________|_______
|                   | |o;    `"-.o`"=._``  '` " ,__.--o;   |
|___________________|_| ;     (#) `-.o `"=.`_.--"_o.-; ;___|___________________
____/______/______/___|o;._    "      `".o|o_.--"    ;o;____/______/______/____
/______/______/______/_"=._o--._        ; | ;        ; ;/______/______/______/_
____/______/______/______/__"=._o--._   ;o|o;     _._;o;____/______/______/____
/______/______/______/______/____"=._o._; | ;_.--"o.--"_/______/______/______/_
____/______/______/______/______/_____"=.o|o_.--""___/______/______/______/____
/______/______/______/______/______/______/______/______/______/______/
*/


import "erc721a/contracts/ERC721A.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

interface ERC721 {
    function transferFrom(address _from, address _to, uint256 _tokenId) external payable;
    function tokenURI(uint256 _tokenId) external view returns (string memory);
}

contract NFTimeCapsuleV2 is ERC721A, Ownable, ReentrancyGuard {
    using Strings for uint256;

    mapping(uint256 => CachedItem) public idsToCachedItem;
    mapping(address => uint) public walletDigups;
    mapping(address => uint) public walletDeposits;

    event TokenBuried(address burier, uint256 tokenId, address buriedContractAddress, uint256 buriedTokenId, string message);
    event TokenDugUp(address digger, uint256 tokenId, address buriedContractAddress, uint256 buriedTokenId, string message);

    error InvalidCapsuleOperation(bool isCapsuleBuried);
    error NotOwner();
    error SupplyMaxMet();
    error UserMaxMet();
    error CapsuleAlreadyDugUp();
    error CapsuleAlreadyBurried();

    uint256 public digUpDate = 0;
    uint256 public maxDeposits = 222;
    uint256 public digupLimit = 1;
    uint256 public depositLimit = 3;

    struct CachedItem {
        uint256 buriedTokenId;
        address buriedTokenAddress;
        bool useItemUri;
        bool isDugUp;
        string message;
    }

    constructor() ERC721A("NFTimeCapsule", "NFTime") {
    }

    function bury() external onlyOwner {
        if (digUpDate != 0)
            revert CapsuleAlreadyBurried();

        // 30 years
        // digUpDate = block.timestamp + 10950 days;

        // TEST VALUE, REMOVE BEFORE PROD
        digUpDate = block.timestamp + 1 days;
    }

    function placeNFTInCapsule(address nftAddress, uint256 tokenId) external nonReentrant {
        _placeNFTInCapsule(nftAddress, tokenId, _msgSender(), "");
    }

    function placeNFTInCapsuleWithMessage(address nftAddress, uint256 tokenId, string memory message) external nonReentrant {
        _placeNFTInCapsule(nftAddress, tokenId, _msgSender(), message);
    }

    function _placeNFTInCapsule(address nftAddress, uint256 tokenId, address mintToAddress, string memory message) internal {
        // capsule is already buried
        if (digUpDate > 0)
            revert CapsuleAlreadyBurried();
        
        // max supply reached
        if (_nextTokenId() > maxDeposits)
            revert SupplyMaxMet();

        // 3 deposits per user
        if (walletDeposits[_msgSender()] >= depositLimit)
            revert UserMaxMet();

        // transfer NFT
        ERC721 nftContract = ERC721(nftAddress);
        nftContract.transferFrom(_msgSender(), address(this), tokenId);
        
        // save cached item
        CachedItem memory capsule = CachedItem(tokenId, nftAddress, false, false, message);
        idsToCachedItem[_nextTokenId()] = capsule;

        emit TokenBuried(_msgSender(), _nextTokenId(), nftAddress, tokenId, message);
        walletDeposits[_msgSender()] += 1;
        _mint(mintToAddress, 1);
    }

    function digUpNFT(uint256 tokenIdToDigUp) external {
        // either not time, or not buried
        if (block.timestamp < digUpDate || digUpDate == 0)
            revert InvalidCapsuleOperation(digUpDate != 0);

        // can't dig up nothing
        if (!_exists(tokenIdToDigUp))
            revert OwnerQueryForNonexistentToken();

        // too many dug up
        if (walletDigups[_msgSender()] >= digupLimit)
            revert UserMaxMet();
        
        CachedItem memory capsuleToDigUp = idsToCachedItem[tokenIdToDigUp];

        if (capsuleToDigUp.isDugUp)
            revert CapsuleAlreadyDugUp();


        // transfer nft to person interacting with contract in future
        ERC721(capsuleToDigUp.buriedTokenAddress).transferFrom(address(this), _msgSender(), capsuleToDigUp.buriedTokenId);

        // set dug up
        idsToCachedItem[tokenIdToDigUp].isDugUp = true;
        walletDigups[_msgSender()] += 1;

        emit TokenDugUp(_msgSender(), tokenIdToDigUp, capsuleToDigUp.buriedTokenAddress, capsuleToDigUp.buriedTokenId, capsuleToDigUp.message);
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory)
    {
        if (!_exists(tokenId)) revert URIQueryForNonexistentToken();

        CachedItem memory capsule = idsToCachedItem[tokenId];

        // base 64 encoding of still buried nft
        string memory base64Svg = "PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHByZXNlcnZlQXNwZWN0UmF0aW89InhNaW5ZTWluIG1lZXQiIHZpZXdCb3g9IjAgMCAxMDgwIDEwODAiPjxnIHRyYW5zZm9ybT0idHJhbnNsYXRlKDU0MCA1NDApIi8+PGcgdHJhbnNmb3JtPSJ0cmFuc2xhdGUoNTQwIDU0MCkiLz48ZyB0cmFuc2Zvcm09Im1hdHJpeCgwIDApIi8+PHJlY3Qgc3R5bGU9InN0cm9rZTojMDAwO3N0cm9rZS13aWR0aDowO3N0cm9rZS1kYXNoYXJyYXk6bm9uZTtzdHJva2UtbGluZWNhcDpidXR0O3N0cm9rZS1kYXNob2Zmc2V0OjA7c3Ryb2tlLWxpbmVqb2luOm1pdGVyO3N0cm9rZS1taXRlcmxpbWl0OjQ7ZmlsbDojNjU2NTY1O2ZpbGwtcnVsZTpub256ZXJvO29wYWNpdHk6MSIgdmVjdG9yLWVmZmVjdD0ibm9uLXNjYWxpbmctc3Ryb2tlIiB4PSItMzMuMDg0IiB5PSItMzMuMDg0IiByeD0iMCIgcnk9IjAiIHdpZHRoPSI2Ni4xNjciIGhlaWdodD0iNjYuMTY3IiB0cmFuc2Zvcm09Im1hdHJpeCgxNC43OCAwIDAgMTQuNjkgNTMzLjUyIDUzMC41OCkiLz48dGV4dCB4bWw6c3BhY2U9InByZXNlcnZlIiBmb250LWZhbWlseT0iUmFsZXdheSIgZm9udC1zaXplPSIxMDUiIGZvbnQtd2VpZ2h0PSI5MDAiIHN0eWxlPSJzdHJva2U6bm9uZTtzdHJva2Utd2lkdGg6MTtzdHJva2UtZGFzaGFycmF5Om5vbmU7c3Ryb2tlLWxpbmVjYXA6YnV0dDtzdHJva2UtZGFzaG9mZnNldDowO3N0cm9rZS1saW5lam9pbjptaXRlcjtzdHJva2UtbWl0ZXJsaW1pdDo0O2ZpbGw6IzAwMDtmaWxsLXJ1bGU6bm9uemVybztvcGFjaXR5OjE7d2hpdGUtc3BhY2U6cHJlIiB0cmFuc2Zvcm09InRyYW5zbGF0ZSg1NDAuNSA1NDAuNSkiPjx0c3BhbiB4PSItNDEwLjM0IiB5PSIzMi45OCI+TkZUaW1lQ2Fwc3VsZTwvdHNwYW4+PC90ZXh0Pjwvc3ZnPg==";

        //Shows a Redeemed State NFT if Capsule is Dugup
        if (capsule.isDugUp)
        {
            base64Svg = "metadata for dug up nft";
        }
        else
        {
            if (capsule.useItemUri)
            {
                return ERC721(capsule.buriedTokenAddress).tokenURI(capsule.buriedTokenId);
            }
        }

        string memory metadata = string(abi.encodePacked('data:application/json,{"name": "Bag #', _toString(tokenId), '", "description": "description here", "image": "data:image/svg+xml;base64,', base64Svg, '"}'));
        return metadata;
    }

    function _startTokenId() internal pure override returns (uint256)
    {
        return 1;
    }

    function toggleShowBuriedTokenMetadata(uint256 tokenId, bool showBuriedTokenMetadata) external
    {
        if (_msgSender() != ownerOf(tokenId))
            revert NotOwner();

        idsToCachedItem[tokenId].useItemUri = showBuriedTokenMetadata;
    }
}   