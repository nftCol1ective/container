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

    mapping(uint256 => string) private _uris;

    constructor(string memory uri) public ERC1155PresetMinterPauser(uri) {
        _mint(msg.sender, GOLD, 10**18, "");
        _mint(msg.sender, SILVER, 10**27, "");
        _mint(msg.sender, ELIXER, 10**18, "");
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
                '<svg width="150" height="150" xmlns="http://www.w3.org/2000/svg">',
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
                    '<rect x="0" y="0" width="150" height="150" stroke="#FFD700" fill="#FFD700" stroke-width="5"/>'
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
