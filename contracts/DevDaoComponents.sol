/**
 *Submitted for verification at Etherscan.io on 2021-08-30
*/

// SPDX-License-Identifier: Unlicense

/*

    DevDaoComponents.sol
    
    This is a utility contract to make it easier for other
    contracts to work with Loot properties.
    
    Call weaponComponents(), chestComponents(), etc. to get 
    an array of attributes that correspond to the item. 
    
    The return format is:
    
    uint256[5] =>
        [0] = Item ID
        [1] = Suffix ID (0 for none)
        [2] = Name Prefix ID (0 for none)
        [3] = Name Suffix ID (0 for none)
        [4] = Augmentation (0 = false, 1 = true)
    
    See the item and attribute tables below for corresponding IDs.

*/

pragma solidity ^0.8.4;

contract DevDaoComponents {

    string[] private osses = [
        "Kali Linux",           // 0
        "Ubuntu",               // 1
        "Windows 1.0",          // 2
        "Android Marshmallow",  // 3
        "Windows 95",           // 4
        "FreeBSD",
        "Slackware Linux",
        "Chromium OS",
        "Windows Vista",
        "Google Chrome OS",
        "macOS",
        "DOS",
        "Linux Mint",
        "GM-NAA I/O"
    ];
    
    string[] private texteditors = [
        "VS Code",
        "Brackets",
        "VIM",
        "Emacs",
        "Brackets",
        "Atom",
        "Notepad++",
        "Pen & Paper",
        "Visual Studio",
        "Sand and Stick",
        "Mental Telepathy",
        "Bluefish",
        "Sublime Text",
        "Dreamweaver",
        "Coda"
    ];
    
    string[] private clothing = [
        "Black Hoodie",
        "White Tanktop",
        "Patagonia Vest",
        "Conference T",
        "Blacked Out",
        "Bulls Jersey",
        "Pink Hoodie",
        "Purple Turtleneck",
        "Bra",
        "Navy Suit",
        "Purple Dress",
        "Platinum Trenchcoat",
        "Bubble Gum Wrapper",
        "Sweat"
    ];
    
    string[] private languages = [
        "TypeScript",
        "JavaScript",
        "Python",
        "Fortran",
        "COBOL",
        "Go",
        "Rust",
        "Swift",
        "PHP",
        "Haskell",
        "Scala",
        "Dart",
        "Java",
        "Julia",
        "C",
        "Kotlin",
        "Velato",
        "ArnoldC",
        "Shakespeare",
        "Piet",
        "Brainfuck",
        "Chicken",
        "Legit",
        "Whitespace"
    ];
    
    string[] private industries = [
        "Government",
        "Black Hat",
        "White Hat",
        "Nonprofit",
        "Money Laundering",
        "Crypto",
        "FAANG",
        "AI Startup",
        "VR",
        "Traveling Consultant",
        "Undercover",
        "Farming",
        "Environmental",
        "Hollywood",
        "Influencer"
    ];
    
    string[] private locations = [
        "Bucharest",
        "Hong Kong",
        "Jackson",
        "Budapest",
        "Sao Palo",
        "Lagos",
        "Omaha",
        "Gold Coast",
        "Paris",
        "Tokyo",
        "Shenzhen",
        "Saint Petersburg",
        "Buenos Aires",
        "Kisumu",
        "Ramallah",
        "Goa",
        "London",
        "Pyongyang"
    ];
    
    string[] private minds = [
        "Abstract",
        "Analytical",
        "Creative",
        "Concrete",
        "Critical",
        "Convergent",
        "Divergent",
        "Anarchist"
    ];
    
    string[] private vibes = [
        "Optimist",
        "Cosmic",
        "Chill",
        "Hyper",
        "Kind",
        "Hater",
        "Phobia",
        "Generous",
        "JonGold"
    ];
    
    function random(string memory input) internal pure returns (uint256) {
        return uint256(keccak256(abi.encodePacked(input)));
    }
    
    function osComponents(uint256 tokenId) public view returns (uint256[5] memory) {
        return pluck(tokenId, "OS", osses);
    }
    
    function textEditorComponents(uint256 tokenId) public view returns (uint256[5] memory) {
        return pluck(tokenId, "TEXTEDITOR", texteditors);
    }
    
    function clothingComponents(uint256 tokenId) public view returns (uint256[5] memory) {
        return pluck(tokenId, "CLOTHING", clothing);
    }
    
    function languageComponents(uint256 tokenId) public view returns (uint256[5] memory) {
        return pluck(tokenId, "LANGUAGE", languages);
    }

    function industryComponents(uint256 tokenId) public view returns (uint256[5] memory) {
        return pluck(tokenId, "INDUSTRY", industries);
    }
    
    function locationComponents(uint256 tokenId) public view returns (uint256[5] memory) {
        return pluck(tokenId, "LOCATION", locations);
    }
    
    function mindComponents(uint256 tokenId) public view returns (uint256[5] memory) {
        return pluck(tokenId, "MIND", minds);
    }
    
    function vibeComponents(uint256 tokenId) public view returns (uint256[5] memory) {
        return pluck(tokenId, "VIBE", vibes);
    }

    function pluck(uint256 tokenId, string memory keyPrefix, string[] memory sourceArray) internal view returns (uint256[5] memory) {
        uint256[5] memory components;
        
        uint256 rand = random(string(abi.encodePacked(keyPrefix, toString(tokenId))));
        
        components[0] = rand % sourceArray.length;
        components[1] = 0;
        components[2] = 0;
        
        uint256 greatness = rand % 21;
        if (greatness > 14) {
            components[1] = (rand % suffixes.length) + 1;
        }
        if (greatness >= 19) {
            components[2] = (rand % namePrefixes.length) + 1;
            components[3] = (rand % nameSuffixes.length) + 1;
            if (greatness == 19) {
                // ...
            } else {
                components[4] = 1;
            }
        }
        return components;
    }
    
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT license
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }
}