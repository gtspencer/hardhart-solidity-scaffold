//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";




contract MessageMeNFT_Old is Ownable, ERC721, ERC721Enumerable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    string internal constant textTagOpen = '<text>';
    string internal constant textTagClose = '</text>';
    string internal constant spanA = '<tspan x="40" dy="25">';
    string internal constant spanZ = '</tspan>';

    struct LedgerData {
        bool claimed;

        bool isPayable;
        uint256 writePrice;

        bool writeActive;

        string header;
        // each person can store 1 message to any other
        mapping(address => string) messages;
        // only last 10 messages are cached for tokenURI, but all can be retrieved
        address[10] lastMessages;
        // current index of the last 10 messages to write to.  this will be the starting point to count back from when getting our messages
        uint writeIndex;
    }
    
    // Counters.counter private _tokenIds;
    mapping(address => LedgerData) public allLedgers;
    // this is used pretty exclusively for tokenuri.  i think its conceptually better to send messages to addresses than to tokenIDs
    mapping(uint => address) public tokensToAddress;

    constructor() ERC721("MessageMe", "MSG") {}

    // edit functions
    function writeFree(address userAddress, string calldata message) external {
        require(!allLedgers[userAddress].isPayable, "token write not free");
        allLedgers[userAddress].messages[msg.sender] = message;
        allLedgers[userAddress].lastMessages[allLedgers[userAddress].writeIndex] = msg.sender;
        allLedgers[userAddress].writeIndex++;
        // if greater than our array, set back to zero
        if (allLedgers[userAddress].writeIndex > 9) {
            allLedgers[userAddress].writeIndex = 0;
        }
    }

    function writePayable(address userAddress, string calldata message) external payable {
        require(msg.value >= allLedgers[userAddress].writePrice, "not enough, chump");
        allLedgers[userAddress].messages[msg.sender] = message;
        allLedgers[userAddress].lastMessages[allLedgers[userAddress].writeIndex] = msg.sender;
        allLedgers[userAddress].writeIndex++;
        // if greater than our array, set back to zero
        if (allLedgers[userAddress].writeIndex > 9) {
            allLedgers[userAddress].writeIndex = 0;
        }
    }

    // owner functions
    function setWritePrice(uint256 writePrice) external {
        allLedgers[msg.sender].isPayable = true;
        allLedgers[msg.sender].writePrice = writePrice;
    }

    function removeWritePrice() external {
        allLedgers[msg.sender].isPayable = false;
    }

    function claimToken() external {
        require(allLedgers[msg.sender].claimed == false, "already claimed");
        _tokenIds.increment();
        uint256 tokenId = _tokenIds.current();
        tokensToAddress[tokenId] = msg.sender;
        allLedgers[msg.sender].claimed = true;
        allLedgers[msg.sender].writeActive = true;
        allLedgers[msg.sender].isPayable = false;
        allLedgers[msg.sender].header = "its nice to see you";
        allLedgers[msg.sender].writeIndex = 0;
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        LedgerData storage copy = allLedgers[tokensToAddress[tokenId]];
        string memory fontColor = 'limegreen;'; 
        
        string memory output = string(abi.encodePacked(
            StringHell.SvgStart(),
            fontColor,
            StringHell.SvgO1(),
            ')" />',
            StringHell.SvgO3()));
        output = string(abi.encodePacked(
            output, 
            copy.messages[copy.lastMessages[0]],
            copy.messages[copy.lastMessages[1]],
            copy.messages[copy.lastMessages[2]], 
            copy.messages[copy.lastMessages[3]],
            copy.messages[copy.lastMessages[4]],
            copy.messages[copy.lastMessages[5]],
            copy.messages[copy.lastMessages[6]],
            copy.messages[copy.lastMessages[7]],
            copy.messages[copy.lastMessages[8]],
            copy.messages[copy.lastMessages[9]]));
        output = string(abi.encodePacked(
            output,
            textTagClose,
            StringHell.SvgEnd()));
        string memory json = Base64.encode(bytes(string(abi.encodePacked(
            '{"name": "Message #', 
            Strings.toString(tokenId), 
            StringHell.Desc(), 
            StringHell.JsonStub(), 
            Base64.encode(bytes(output)), '"}'))));
        output = string(abi.encodePacked(StringHell.Json(), json));
        return output;
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal virtual override(ERC721, ERC721Enumerable) {
        ERC721Enumerable._beforeTokenTransfer(from, to, tokenId);
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721, ERC721Enumerable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}

/// @title StringHell
/// @notice If you know a smarter way I could have done this feel free to email me
/// @author Sterling Crispin <sterlingcrispin@gmail.com>
/// my contract is giant 
/// I had to do something with these strings
library StringHell {
    string internal constant svgStart = '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 400 400" width="800" height="800"><defs><linearGradient id="grad"  x1="0" x2="0" y1="0" y2="1"><stop offset="0%" stop-color="dimgrey" /><stop offset="10%" stop-color="black" /></linearGradient><radialGradient id="grad2" cx="0.5" cy="0.9" r="1.2" fx="0.5" fy="0.9" spreadMethod="repeat"><stop offset="0%" stop-color="red"/><stop offset="100%" stop-color="blue"/></radialGradient></defs><style>.base { fill:';
    string internal constant svgO1 = 'font-family: monospace; font-size: 15px; }</style><rect y="8" width="100%" height="100%" fill="url(#grad';
    string internal constant svgEnd = '<rect width="100%" height="100%" fill="none" stroke="dimgrey" stroke-width="20"/><circle cx="20" cy="395" r="3" fill="limegreen"/></svg>';
    string internal constant svgB1 = '<rect y="50%" width="100%" height="100%" fill="url(#grad';
    string internal constant svgO3 = '<text x="20" y="60" class="base">//usr: ';
    string internal constant svgP2 = '<text x="20" y="250" class="base">//pub: '; 
    string internal constant desc = '", "description": "Message is an experiment in communication. Write via contract, refresh metadata. Be nice. https://sterlingcrispin.com/message.html",';
    string internal constant json = 'data:application/json;base64,';
    string internal constant jsonStub = '], "image": "data:image/svg+xml;base64,';
    
    function SvgStart() external pure returns (string memory){
        return svgStart;
    }
    function SvgO1() external pure returns (string memory){
        return svgO1;
    }
    function SvgEnd() external pure returns (string memory){
        return svgEnd;
    }
    function SvgB1() external pure returns (string memory){
        return svgB1;
    }
    function SvgO3() external pure returns (string memory){
        return svgO3;
    }
    function SvgP2() external pure returns (string memory){
        return svgP2;
    }
    function Desc() external pure returns (string memory){
        return desc;
    }
    function Json() external pure returns (string memory){
        return json;
    }
    function JsonStub() external pure returns (string memory){
        return jsonStub;
    }
}

/// [MIT License]
/// @title Base64
/// @notice Provides a function for encoding some bytes in base64
/// @author Brecht Devos <brecht@loopring.org>
library Base64 {
    bytes internal constant TABLE = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
    /// @notice Encodes some bytes to the base64 representation
    function encode(bytes memory data) internal pure returns (string memory) {
        uint256 len = data.length;
        if (len == 0) return "";
        uint256 encodedLen = 4 * ((len + 2) / 3);
        bytes memory result = new bytes(encodedLen + 32);
        bytes memory table = TABLE;

        assembly {
            let tablePtr := add(table, 1)
            let resultPtr := add(result, 32)
            for {
                let i := 0
            } lt(i, len) {

            } {
                i := add(i, 3)
                let input := and(mload(add(data, i)), 0xffffff)
                let out := mload(add(tablePtr, and(shr(18, input), 0x3F)))
                out := shl(8, out)
                out := add(out, and(mload(add(tablePtr, and(shr(12, input), 0x3F))), 0xFF))
                out := shl(8, out)
                out := add(out, and(mload(add(tablePtr, and(shr(6, input), 0x3F))), 0xFF))
                out := shl(8, out)
                out := add(out, and(mload(add(tablePtr, and(input, 0x3F))), 0xFF))
                out := shl(224, out)
                mstore(resultPtr, out)
                resultPtr := add(resultPtr, 4)
            }
            switch mod(len, 3)
            case 1 {
                mstore(sub(resultPtr, 2), shl(240, 0x3d3d))
            }
            case 2 {
                mstore(sub(resultPtr, 1), shl(248, 0x3d))
            }
            mstore(result, encodedLen)
        }
        return string(result);
    }
}