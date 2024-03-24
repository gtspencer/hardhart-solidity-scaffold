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
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

interface ERC721 {
    function transferFrom(address _from, address _to, uint256 _tokenId) external payable;
    function tokenURI(uint256 _tokenId) external view returns (string memory);
}

interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

interface ERC1155 {
    function transferFrom(address _from, address _to, uint256 _tokenId) external payable;
    function tokenURI(uint256 _tokenId) external view returns (string memory);
}

interface IERC721Metadata {
    function name() external view returns (string memory);
}

contract NFTimeCapsuleV2 is ERC721A, Ownable {
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
    uint256 public maxDeposits = 2053;
    uint256 public digupLimit = 1;
    uint256 public depositLimit = 3;

    struct CachedItem {
        uint256 buriedTokenId;
        address buriedTokenAddress;
        address burier;
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
        digUpDate = block.timestamp + 10950 days;
    }

    struct TimeLeft {
        uint256 year;
        uint256 day;
        uint256 hour;
        uint256 minute;
        uint256 second;
    }

    function getTimeLeft() public view returns (TimeLeft memory) {
        TimeLeft memory timeLeft;

        if (digUpDate < block.timestamp) {
            timeLeft.year = 0;
            timeLeft.day = 0;
            timeLeft.hour = 0;
            timeLeft.minute = 0;
            timeLeft.second = 0;
            return timeLeft;
        }

        uint256 timestamp = digUpDate - block.timestamp;

        uint256 yearsLeft = timestamp / 31536000;

        // calculate ticks left after years
        timestamp = timestamp - (yearsLeft * 31536000);

        uint256 daysLeft = timestamp / 86400;

        // calculate ticks left after days
        timestamp = timestamp - (daysLeft * 86400);

        uint256 hoursLeft = timestamp / 3600;

        // calculate ticks left after hours
        timestamp = timestamp - (hoursLeft * 3600);

        uint256 minutesLeft = timestamp / 60;

        // calculate ticks left after minutes
        timestamp = timestamp - (minutesLeft * 60);

        timeLeft.year = yearsLeft;
        timeLeft.day = daysLeft;
        timeLeft.hour = hoursLeft;
        timeLeft.minute = minutesLeft;
        timeLeft.second = timestamp;

        return timeLeft;
    }

    function placeNFTInCapsule(address nftAddress, uint256 tokenId, bool is721) external {
        _placeNFTInCapsule(nftAddress, tokenId, _msgSender(), is721, "");
    }

    function placeNFTInCapsuleWithMessage(address nftAddress, uint256 tokenId, bool is721, string memory message) external {
        _placeNFTInCapsule(nftAddress, tokenId, _msgSender(), is721, message);
    }

    function _placeNFTInCapsule(address nftAddress, uint256 tokenId, address mintToAddress, bool is721, string memory message) internal {
        if (address(this) == nftAddress)
            revert InvalidCapsuleOperation(digUpDate != 0);

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
        if (is721)
        {
            ERC721 nftContract = ERC721(nftAddress);
            nftContract.transferFrom(_msgSender(), address(this), tokenId);
        }
        else
        {

        }
        

        // save cached item
        CachedItem memory capsule = CachedItem(tokenId, nftAddress, _msgSender(), false, false, message);
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

        walletDigups[_msgSender()] += 1;

        // transfer nft to person interacting with contract in future
        ERC721(capsuleToDigUp.buriedTokenAddress).transferFrom(address(this), _msgSender(), capsuleToDigUp.buriedTokenId);

        // set dug up
        idsToCachedItem[tokenIdToDigUp].isDugUp = true;

        emit TokenDugUp(_msgSender(), tokenIdToDigUp, capsuleToDigUp.buriedTokenAddress, capsuleToDigUp.buriedTokenId, capsuleToDigUp.message);
    }

    struct TokenURIInfo {
        string buriedContractName;
        string buriedTokenIdString;
        string tokenIdString;
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory)
    {
        if (!_exists(tokenId)) revert URIQueryForNonexistentToken();

        CachedItem storage capsule = idsToCachedItem[tokenId];

        TokenURIInfo memory tokenIdInfo;
        tokenIdInfo.buriedContractName = "";

        try IERC721Metadata(capsule.buriedTokenAddress).name() returns (string memory name) {
            tokenIdInfo.buriedContractName = name;
        }catch (bytes memory) {

        }

        TimeLeft memory timeLeft = getTimeLeft();

        tokenIdInfo.tokenIdString = _toString(tokenId);
        tokenIdInfo.buriedTokenIdString = _toString(capsule.buriedTokenId);
        string memory base64Svg = Base64.encode(abi.encodePacked('<svg viewBox="0 0 1658 987" xmlns="http://www.w3.org/2000/svg"><mask id="a" fill="#fff"><path fill-rule="evenodd" clip-rule="evenodd" d="M121.43 153.937c0-85.052 68.948-154 154-154h1132c85.05 0 154 68.948 154 154v84h73c11.05 0 20 8.954 20 20v471c0 11.046-8.95 20-20 20h-73v84c0 85.052-68.95 154-154 154h-1132c-85.052 0-154-68.948-154-154v-84h-98c-11.046 0-20-8.954-20-20v-471c0-11.046 8.954-20 20-20h98v-84Z"/></mask><path fill-rule="evenodd" clip-rule="evenodd" d="M121.43 153.937c0-85.052 68.948-154 154-154h1132c85.05 0 154 68.948 154 154v84h73c11.05 0 20 8.954 20 20v471c0 11.046-8.95 20-20 20h-73v84c0 85.052-68.95 154-154 154h-1132c-85.052 0-154-68.948-154-154v-84h-98c-11.046 0-20-8.954-20-20v-471c0-11.046 8.954-20 20-20h98v-84Z" fill="#F7F0E4"/><path d="M1561.43 237.937h-20v20h20v-20Zm0 511v-20h-20v20h20Zm-1440 0h20v-20h-20v20Zm0-511v20h20v-20h-20Zm154-258c-96.098 0-174 77.902-174 174h40c0-74.006 59.994-134 134-134v-40Zm1132 0h-1132v40h1132v-40Zm174 174c0-96.098-77.9-174-174-174v40c74.01 0 134 59.994 134 134h40Zm0 84v-84h-40v84h40Zm-20 20h73v-40h-73v40Zm73 0 .02.001c.01 0 .01 0 0-.001l-.01-.003c-.01-.002-.01-.004-.02-.005 0-.003-.01-.005 0-.004 0 .002 0 .006.01.012s.01.011.01.014v-.008c0-.004-.01-.008-.01-.013v-.017.024h40c0-22.091-17.91-40-40-40v40Zm0 0v471h40v-471h-40Zm0 471v.024-.017c0-.005.01-.009.01-.013v-.008c0 .003 0 .008-.01.014s-.01.01-.01.012c-.01.001 0-.001 0-.004.01-.001.01-.003.02-.005l.01-.003c.01-.001.01-.001 0-.001l-.02.001v40c22.09 0 40-17.909 40-40h-40Zm0 0h-73v40h73v-40Zm-53 104v-84h-40v84h40Zm-174 174c96.1 0 174-77.902 174-174h-40c0 74.006-59.99 134-134 134v40Zm-1132 0h1132v-40h-1132v40Zm-174-174c0 96.098 77.902 174 174 174v-40c-74.006 0-134-59.994-134-134h-40Zm0-84v84h40v-84h-40Zm-78 20h98v-40h-98v40Zm-40-40c0 22.091 17.909 40 40 40v-40l-.024-.001.003.001.014.003.013.005.008.004-.014-.012-.012-.014.004.008.005.013.003.014.001.003-.001-.024h-40Zm0-471v471h40v-471h-40Zm40-40c-22.091 0-40 17.909-40 40h40l.001-.024-.001.003-.003.014-.005.013-.004.008.012-.014.014-.012-.008.004-.013.005-.014.003-.003.001.024-.001v-40Zm98 0h-98v40h98v-40Zm-20-64v84h40v-84h-40Z" fill="#ECD8BA" mask="url(#a)"/><rect x="466.43" y="400.937" width="61" height="47" rx="3" fill="#D5B290"/><rect x="284.43" y="399.937" width="61" height="47" rx="3" fill="#D5B290"/><rect x="632.36" y="399.937" width="61" height="47" rx="3" fill="#D5B290"/><rect x="829.716" y="399.937" width="61" height="47" rx="3" fill="#D5B290"/><rect x="1056.885" y="397.021" width="61" height="47" rx="3" fill="#D5B290"/><path stroke="#F5E6CE" stroke-width="15" stroke-linecap="round" stroke-dasharray="30 30" d="m137.877 289.49-2.894 409m1410.897-408-2.9 409"/><text style="fill:#333;font-family:&quot;Courier New&quot;;font-size:36.5px;white-space:pre" x="287.496" y="254.108"><tspan x="353.437" y="432.188" style="font-size:36.5px;word-spacing:0">years</tspan></text><text style="fill:#333;font-family:&quot;Courier New&quot;;font-size:36.5px;white-space:pre" x="538.772" y="434.799">days</text><text style="fill:#333;font-family:Courier New;font-size:36.5px;white-space:pre" x="363.196" y="461.631"><tspan x="707.139" y="433.494" style="font-size:36.5px;word-spacing:0">hours</tspan></text><text style="fill:#333;font-family:Courier New;font-size:36.5px;white-space:pre" x="240.069" y="316.757"><tspan x="897.254" y="433.494" style="font-size:36.5px;word-spacing:0">minutes</tspan></text><text style="fill:#333;font-family:Courier New;font-size:36.5px;white-space:pre" x="1125.607" y="429.578">seconds until open</text><text style="fill:#333;font-family:&quot;Courier New&quot;;font-size:36.5px;text-anchor:middle;white-space:pre" x="313.587" y="435.874">', _toString(timeLeft.year), '</text><text style="fill:#333;font-family:&quot;Courier New&quot;;font-size:36.5px;text-anchor:middle;white-space:pre" x="496.311" y="436.527">', _toString(timeLeft.day), '</text><text style="fill:#333;font-family:&quot;Courier New&quot;;font-size:36.5px;text-anchor:middle;white-space:pre" x="662.068" y="436.527">', _toString(timeLeft.hour), '</text><text style="fill:#333;font-family:&quot;Courier New&quot;;font-size:36.5px;text-anchor:middle;white-space:pre" x="860.488" y="436.527">', _toString(timeLeft.minute), '</text><text style="fill:#333;font-family:&quot;Courier New&quot;;font-size:36.5px;text-anchor:middle;white-space:pre" x="1086.232" y="433.916">', _toString(timeLeft.second), '</text><text style="fill:#cbb798;font-family:Courier New;font-size:93px;font-weight:700;white-space:pre;text-anchor:middle" x="829.492" y="173.478">Toymakers Present</text><text style="fill:#333;font-family:Courier New;font-size:97px;font-weight:700;text-anchor:middle;white-space:pre" x="829.492" y="288.176">TIME CAPSULE TICKET</text><text style="fill:#cbb798;font-family:Courier New;font-size:46.2px;white-space:pre" x="229.548" y="240.657"><tspan x="269.532" y="767.046" style="font-size:46.2px;word-spacing:0">and is owned by</tspan></text><text style="fill:#333;font-family:Courier New;font-size:46.2px;white-space:pre" x="272.86" y="816.061">', Strings.toHexString(uint256(uint160(ownerOf(tokenId))), 20),'</text><text style="fill:#333;font-family:Courier New;font-size:46.2px;white-space:pre" x="272.86" y="619.999">', tokenIdInfo.buriedContractName, ' #', tokenIdInfo.buriedTokenIdString, '</text><text style="fill:#cbb798;font-family:Courier New;font-size:46.2px;white-space:pre" x="232.359" y="142.627"><tspan x="272.343" y="669.015" style="font-size:46.2px;word-spacing:0">was buried in 2023 by</tspan></text><text style="fill:#333;font-family:Courier New;font-size:46.2px;white-space:pre" x="273.658" y="718.03">', Strings.toHexString(uint256(uint160(capsule.burier)), 20),'</text></svg>'));

        if (capsule.useItemUri)
        {
            return ERC721(capsule.buriedTokenAddress).tokenURI(capsule.buriedTokenId);
        }

        string memory metadata = string(abi.encodePacked('data:application/json,{"name": "Ticket #', tokenIdInfo.tokenIdString, '", "description": "A deposit stub for the NFT Time Capsule.  Made by Toymakers.", "attributes": [{"display_type": "date", "trait_type": "Capsule Open", "value":', _toString(digUpDate), '}, {"trait_type": "Buried Token Address", "value":"', Strings.toHexString(uint256(uint160(capsule.buriedTokenAddress)), 20), '"}, {"trait_type": "Buried Token Id", "value":"', tokenIdInfo.buriedTokenIdString, '"}, {"trait_type": "Buried Token Name", "value":"', tokenIdInfo.buriedContractName, '"}], "image": "data:image/svg+xml;base64,', base64Svg, '"}'));
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

    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external returns (bytes4)
    {
        return 0xf23a6e61;
    }

    function onERC1155BatchReceived(
    address operator,
    address from,
    uint256[] calldata ids,
    uint256[] calldata values,
    bytes calldata data
    ) external returns (bytes4)
    {
        return 0xbc197c81;
    }

    function onERC721Received(address _operator, address _from, uint256 _tokenId, bytes calldata _data) external returns(bytes4)
    {
        return 0x150b7a02;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
    // The interface IDs are constants representing the first 4 bytes
    // of the XOR of all function selectors in the interface.
    // See: [ERC165](https://eips.ethereum.org/EIPS/eip-165)
    // (e.g. `bytes4(i.functionA.selector ^ i.functionB.selector ^ ...)`)
    return
        interfaceId == 0x01ffc9a7 || // ERC165 interface ID for ERC165.
        interfaceId == 0x80ac58cd || // ERC165 interface ID for ERC721.
        interfaceId == 0x5b5e139f || // ERC165 interface ID for ERC721Metadata.
        interfaceId == 0x4e2312e0 || // ERC-1155 ERC1155TokenReceiver
        interfaceId == 0x150b7a02;   // ERC721 Receiver interface ID
    }
 }
