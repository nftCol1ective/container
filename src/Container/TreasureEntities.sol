//SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC1155/presets/ERC1155PresetMinterPauser.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "base64-sol/base64.sol";
import "../Libraries/HexStrings.sol";

contract TreasureEntities is ERC1155PresetMinterPauser, Ownable {
    using Strings for uint256;
    using HexStrings for uint160;

    uint256 public constant GOLD = 0;
    uint256 public constant SILVER = 1;
    uint256 public constant ELIXER = 2;

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
        addValue("ELIXER");
        _mint(msg.sender, ELIXER, 10**18, "");
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
            render = string(
                abi.encodePacked(
                    '<path d="m213.92 372.08c-5.77 0-10.45-4.68-10.45-10.45 0-29.8-7.6-57.68-21.4-78.5-12.92-19.5-29.67-30.23-47.16-30.23s-34.23 10.74-47.16 30.23c-13.8 20.82-21.4 48.7-21.4 78.5 0 5.77-4.68 10.45-10.44 10.45s-10.44-4.68-10.44-10.45c0-33.86 8.83-65.84 24.88-90.04 16.92-25.53 39.85-39.59 64.57-39.59s47.65 14.06 64.57 39.58c16.04 24.2 24.88 56.18 24.88 90.04 0 5.78-4.68 10.46-10.45 10.46z" fill="#36C1E2"/>',
                    '<path d="m211.46 0.70996-73.84 0.28-74.46-0.28-62.79 81.68-0.20999 0.28 137.74 280.8 136.07-280.66-62.51-82.1z" fill="#EA9C00"/>',
                    '<path d="m63.16 0.70996-62.79 81.68 74.74 1.39-11.95-83.07z" fill="#fff" opacity=".5"/>',
                    '<path d="m63.16 0.70996 7.95 78.77-62.55 3.33 63.76 0.93 26.81 106.55-23.33-106.65h66.96l-63.83-3.12 37.44-37.72-41.53 35.94-11.68-78.03z" fill="#fff"/>',
                    '<path d="m63.16 0.70996 74.46 0.28-62.37 82.38-12.09-82.66z" fill="#fff" opacity=".75"/>',
                    '<path d="m197.64 82.67-60.02-81.68-62.51 82.79 122.53-1.11z" fill="#fff" opacity=".95"/>',
                    '<path d="m197.64 82.67-60.02-81.68 73.84-0.28-13.82 81.96z" fill="#fff" opacity=".6"/>',
                    '<path d="m197.64 82.67 76.33 0.14-62.51-82.1-13.82 81.96z" fill="#fff" opacity=".4"/>',
                    '<path d="m197.64 82.67 76.33 0.14-136.07 280.66 59.74-280.8z" fill="#fff" opacity=".6"/>',
                    '<path d="m197.64 82.67-122.39 1.11 62.65 279.69 59.74-280.8z" fill="#fff" opacity=".8"/>',
                    '<path d="m30.15 206.13c-12.55-13.12 2.8-25.95 16.06-29.46l-10.8-21.89c-26.38 10.13-42.04 53.65-14.21 72.81 15.58 13.87 65.77 16.68 67.54-3.36-1.34-14.29-43.54-0.72-58.59-18.1z" fill="#36C1E2"/>',
                    '<path d="m40.71 165.52c-11.3 6.13-20.66 17.93-15.34 28.73 0 0 2.39-12.7 20.96-17.34l-5.62-11.39z" fill="#1A9FB5"/>',
                    '<path d="m244.14 206.13c12.55-13.12-2.8-25.95-16.06-29.46l10.8-21.89c26.38 10.13 42.04 53.65 14.21 72.81-15.58 13.87-65.77 16.68-67.54-3.36 1.34-14.29 43.54-0.72 58.59-18.1z" fill="#36C1E2"/>',
                    '<path d="m233.58 165.52c11.3 6.13 20.66 17.93 15.34 28.73 0 0-2.39-12.7-20.96-17.34l5.62-11.39z" fill="#1A9FB5"/>',
                    '<path d="m196.47 151.04c-19.52-6.76 3.32-54.09 18.99-38.24 4.82 4.88 2.4 15.11 0.36 20.64-4 10.88-9.32 21.08-19.35 17.6z" fill="#fff"/>',
                    '<path d="m213.08 124.64c-1.28-5.73-8.8-8.55-11.9-4.55 3.32 1.23 5.32 4.23 4.52 6.94-0.85 2.85-4.49 4.29-8.15 3.21-0.48-0.14-0.94-0.32-1.37-0.54-2.31 6.09-2.71 12.55 4.98 14.46 8.83 2.19 12.94-14.95 11.92-19.52z" fill="#330017"/>',
                    '<path d="m136.6 158.41c22.091 0 40-10.736 40-23.98s-17.909-23.98-40-23.98-40 10.736-40 23.98 17.909 23.98 40 23.98z" fill="#36C1E2"/>',
                    '<path d="m136.6 124.63c6.854 0 12.41-4.101 12.41-9.16s-5.556-9.16-12.41-9.16-12.41 4.101-12.41 9.16 5.556 9.16 12.41 9.16z" fill="#330017"/>',
                    '<path d="m156.42 128.73c-0.08 7.29-5.92 12.81-12.56 14.82-7.28 2.2-15.94 0.72-21.44-4.74-2.72-2.7-4.4-6.22-4.44-10.08-0.03-2.73-4.28-2.74-4.25 0 0.09 9.09 7.02 16.17 15.35 18.81 8.83 2.81 19.41 0.83 26.03-5.84 3.44-3.47 5.52-8.07 5.57-12.97 0.02-2.74-4.23-2.74-4.26 0z" fill="#330017"/>',
                    '<path d="m216.96 155.1c1.463-7.507-5.639-15.209-15.862-17.201-10.223-1.993-19.697 2.478-21.161 9.985-1.463 7.508 5.639 15.21 15.862 17.202 10.223 1.993 19.697-2.478 21.161-9.986z" fill="#36C1E2"/>',
                    '<path d="m75.77 151.04c19.52-6.76-3.32-54.09-18.99-38.24-4.82 4.88-2.4 15.11-0.36 20.64 4 10.88 9.31 21.08 19.35 17.6z" fill="#fff"/>',
                    '<path d="m59.15 124.64c1.28-5.73 8.8-8.55 11.9-4.55-3.32 1.23-5.32 4.23-4.52 6.94 0.85 2.85 4.49 4.29 8.15 3.21 0.48-0.14 0.94-0.32 1.37-0.54 2.31 6.09 2.71 12.55-4.98 14.46-8.83 2.19-12.94-14.95-11.92-19.52z" fill="#330017"/>',
                    '<path d="m76.342 165.05c10.223-1.993 17.325-9.694 15.862-17.202s-10.937-11.978-21.161-9.986c-10.223 1.993-17.325 9.694-15.862 17.202 1.4633 7.507 10.937 11.978 21.161 9.986z" fill="#36C1E2"/>',
                    '<path d="m45.16 89.85 19.76 15.38-15.38-19.76 15.38-19.76-19.76 15.38-19.77-15.38 15.38 19.76-15.38 19.76 19.77-15.38z" fill="#fff"/>',
                    '<path d="m193.05 80.92-13.54 34.85 21.69-30.46 34.84 13.54-30.45-21.68 13.54-34.85-21.69 30.46-34.84-13.54 30.45 21.68z" fill="#fff"/>',
                    '<path d="m104.06 234.71-22.09 24.58 27.45-18.4 24.58 22.1-18.4-27.46 22.1-24.58-27.46 18.4-24.58-22.09 18.4 27.45z" fill="#fff"/>'
                )
            );
        }
        if (id == SILVER) {
            render = string(
                abi.encodePacked(
                    '<rect x="0" y="0" width="150" height="150" stroke="#C0C0C0" fill="#C0C0C0" stroke-width="5"/>'
                )
            );
        }
        if (id == ELIXER) {
            render = string(
                abi.encodePacked(
                    '<rect x="0" y="0" width="150" height="150" stroke="#00FFFF" fill="#00FFFF" stroke-width="5"/>'
                )
            );
        }
        return render;
    }
}
