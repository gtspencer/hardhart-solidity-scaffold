//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

abstract contract INFTWrapper {
    address nftAddress;

    enum Category {
        Item,
        Decor
    }

    enum Attribute {
        ThreeD,
        TwoD
    }

    mapping(Category => string) CategoryMapping;

    Category _category;

    function getCategory() external view returns (string memory) {
        return CategoryMapping[_category];
    }

    /**
     * @dev Returns wrapped token info in game base64 readable json string
     */
    function getTokenInfo() external view returns (string memory) {

    }

/** 
* JSON Game Wrapper Format
    {
        "NFT": {
            "Category": "Item",
            "NFT_Attributes": [
                {
                "trait_type": "Base", 
                "value": "Starfish"
                }, 
                {
                "trait_type": "Eyes", 
                "value": "Big"
                }, 
                {
                "trait_type": "Mouth", 
                "value": "Surprised"
                }
            ]
        }
    }
*/
}