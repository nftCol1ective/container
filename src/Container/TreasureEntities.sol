//SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC1155/presets/ERC1155PresetMinterPauser.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "base64-sol/base64.sol";
import "../Libraries/HexStrings.sol";
import "../Libraries/SvgElements.sol";

contract TreasureEntities is ERC1155PresetMinterPauser, Ownable, SvgElements {
    using Strings for uint256;
    using HexStrings for uint160;

    uint256 public constant GOLD = 0;
    uint256 public constant SILVER = 1;
    uint256 public constant ELIXIR = 2;

    struct Entities {
        uint256 sizeOfMapping;
        mapping(uint256 => string) entityNames;
    }

    Entities public entityList;

    function addValue(string memory entityName) private onlyOwner {
        entityList.sizeOfMapping++;
        entityList.entityNames[entityList.sizeOfMapping] = entityName;
    }

    mapping(uint256 => string) private _uris;

    constructor(string memory uri) public ERC1155PresetMinterPauser(uri) {
        addValue("GOLD");
        _mint(msg.sender, GOLD, 10**18, "");
        addValue("SILVER");
        _mint(msg.sender, SILVER, 10**27, "");
        addValue("ELIXIR");
        _mint(msg.sender, ELIXIR, 10**18, "");
    }

    function getEntitiesAvailable() public view returns (string[] memory) {
        string[] memory entitiesArray = new string[](entityList.sizeOfMapping);
        for (uint256 i = 0; i < entityList.sizeOfMapping; i++) {
            entitiesArray[i] = entityList.entityNames[i + 1];
        }
        return entitiesArray;
    }

    function uri(uint256 tokenId) public view override returns (string memory) {
        return (_uris[tokenId]);
    }

    function setTokenUri(uint256 tokenId, string memory uri) public onlyOwner {
        /**
         * In case we want to restrict updating the token uri
         */
        // require(bytes(_uris[tokenId]).length == 0, "URI already set");
        _uris[tokenId] = uri;
    }

    function _ownerOf(uint256 tokenId) internal view returns (bool) {
        return balanceOf(msg.sender, tokenId) != 0;
    }

    function tokenUri(uint256 id) public view returns (string memory) {
        string memory _name = string(abi.encodePacked("Treasure Entity #", id.toString()));
        string memory _description = string(abi.encodePacked("Treasure Entities"));
        string memory image = Base64.encode(bytes(generateSVGofTokenById(id)));

        return
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    Base64.encode(
                        bytes(
                            abi.encodePacked(
                                '{"name":"',
                                _name,
                                '", "description":"',
                                _description,
                                '", "image": "',
                                "data:image/svg+xml;base64,",
                                image,
                                '", "attributes": [{ "trait_type": "Used", "value": "false" }]',
                                '"}'
                            )
                        )
                    )
                )
            );
    }

    function generateSVGofTokenById(uint256 id) internal view returns (string memory) {
        string memory svg = string(
            abi.encodePacked(
                '<svg viewBox="0 0 274 373" xmlns="http://www.w3.org/2000/svg">',
                renderTokenById(id),
                "</svg>"
            )
        );

        return svg;
    }

    // Need to update this function to be more generic
    // We need to add another unique render function here in case we want to add some animation to the svg image
    function renderTokenById(uint256 id) public view returns (string memory) {
        string memory render;
        if (id == GOLD) {
            render = goldSVG;
        }
        if (id == SILVER) {
            render = silverSVG;
        }
        if (id == ELIXIR) {
            render = elixirSVG;
        }
        return render;
    }
}
