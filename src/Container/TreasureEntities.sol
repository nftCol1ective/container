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
            render = string(
                abi.encodePacked(
                    '<path d="m213.92 372.08c-5.77 0-10.45-4.68-10.45-10.45 0-29.8-7.6-57.68-21.4-78.5-12.92-19.5-29.67-30.23-47.16-30.23s-34.23 10.74-47.16 30.23c-13.8 20.82-21.4 48.7-21.4 78.5 0 5.77-4.68 10.45-10.44 10.45s-10.44-4.68-10.44-10.45c0-33.86 8.83-65.84 24.88-90.04 16.92-25.53 39.85-39.59 64.57-39.59s47.65 14.06 64.57 39.58c16.04 24.2 24.88 56.18 24.88 90.04 0 5.78-4.68 10.46-10.45 10.46z" fill="#36C1E2"/><path d="m211.46 0.70996-73.84 0.28-74.46-0.28-62.79 81.68-0.20999 0.28 137.74 280.8 136.07-280.66-62.51-82.1z" fill="#EA9C00"/><path d="m63.16 0.70996-62.79 81.68 74.74 1.39-11.95-83.07z" fill="#fff" opacity=".5"/><path d="m63.16 0.70996 7.95 78.77-62.55 3.33 63.76 0.93 26.81 106.55-23.33-106.65h66.96l-63.83-3.12 37.44-37.72-41.53 35.94-11.68-78.03z" fill="#fff"/>',
                    '<path d="m63.16 0.70996 74.46 0.28-62.37 82.38-12.09-82.66z" fill="#fff" opacity=".75"/><path d="m197.64 82.67-60.02-81.68-62.51 82.79 122.53-1.11z" fill="#fff" opacity=".95"/><path d="m197.64 82.67-60.02-81.68 73.84-0.28-13.82 81.96z" fill="#fff" opacity=".6"/><path d="m197.64 82.67 76.33 0.14-62.51-82.1-13.82 81.96z" fill="#fff" opacity=".4"/>',
                    '<path d="m197.64 82.67 76.33 0.14-136.07 280.66 59.74-280.8z" fill="#fff" opacity=".6"/><path d="m197.64 82.67-122.39 1.11 62.65 279.69 59.74-280.8z" fill="#fff" opacity=".8"/><path d="m30.15 206.13c-12.55-13.12 2.8-25.95 16.06-29.46l-10.8-21.89c-26.38 10.13-42.04 53.65-14.21 72.81 15.58 13.87 65.77 16.68 67.54-3.36-1.34-14.29-43.54-0.72-58.59-18.1z" fill="#36C1E2"/><path d="m40.71 165.52c-11.3 6.13-20.66 17.93-15.34 28.73 0 0 2.39-12.7 20.96-17.34l-5.62-11.39z" fill="#1A9FB5"/><path d="m244.14 206.13c12.55-13.12-2.8-25.95-16.06-29.46l10.8-21.89c26.38 10.13 42.04 53.65 14.21 72.81-15.58 13.87-65.77 16.68-67.54-3.36 1.34-14.29 43.54-0.72 58.59-18.1z" fill="#36C1E2"/>',
                    '<path d="m233.58 165.52c11.3 6.13 20.66 17.93 15.34 28.73 0 0-2.39-12.7-20.96-17.34l5.62-11.39z" fill="#1A9FB5"/><path d="m196.47 151.04c-19.52-6.76 3.32-54.09 18.99-38.24 4.82 4.88 2.4 15.11 0.36 20.64-4 10.88-9.32 21.08-19.35 17.6z" fill="#fff"/><path d="m213.08 124.64c-1.28-5.73-8.8-8.55-11.9-4.55 3.32 1.23 5.32 4.23 4.52 6.94-0.85 2.85-4.49 4.29-8.15 3.21-0.48-0.14-0.94-0.32-1.37-0.54-2.31 6.09-2.71 12.55 4.98 14.46 8.83 2.19 12.94-14.95 11.92-19.52z" fill="#330017"/><path d="m136.6 158.41c22.091 0 40-10.736 40-23.98s-17.909-23.98-40-23.98-40 10.736-40 23.98 17.909 23.98 40 23.98z" fill="#36C1E2"/>',
                    '<path d="m136.6 124.63c6.854 0 12.41-4.101 12.41-9.16s-5.556-9.16-12.41-9.16-12.41 4.101-12.41 9.16 5.556 9.16 12.41 9.16z" fill="#330017"/><path d="m156.42 128.73c-0.08 7.29-5.92 12.81-12.56 14.82-7.28 2.2-15.94 0.72-21.44-4.74-2.72-2.7-4.4-6.22-4.44-10.08-0.03-2.73-4.28-2.74-4.25 0 0.09 9.09 7.02 16.17 15.35 18.81 8.83 2.81 19.41 0.83 26.03-5.84 3.44-3.47 5.52-8.07 5.57-12.97 0.02-2.74-4.23-2.74-4.26 0z" fill="#330017"/><path d="m216.96 155.1c1.463-7.507-5.639-15.209-15.862-17.201-10.223-1.993-19.697 2.478-21.161 9.985-1.463 7.508 5.639 15.21 15.862 17.202 10.223 1.993 19.697-2.478 21.161-9.986z" fill="#36C1E2"/><path d="m75.77 151.04c19.52-6.76-3.32-54.09-18.99-38.24-4.82 4.88-2.4 15.11-0.36 20.64 4 10.88 9.31 21.08 19.35 17.6z" fill="#fff"/>',
                    '<path d="m59.15 124.64c1.28-5.73 8.8-8.55 11.9-4.55-3.32 1.23-5.32 4.23-4.52 6.94 0.85 2.85 4.49 4.29 8.15 3.21 0.48-0.14 0.94-0.32 1.37-0.54 2.31 6.09 2.71 12.55-4.98 14.46-8.83 2.19-12.94-14.95-11.92-19.52z" fill="#330017"/><path d="m76.342 165.05c10.223-1.993 17.325-9.694 15.862-17.202s-10.937-11.978-21.161-9.986c-10.223 1.993-17.325 9.694-15.862 17.202 1.4633 7.507 10.937 11.978 21.161 9.986z" fill="#36C1E2"/><path d="m45.16 89.85 19.76 15.38-15.38-19.76 15.38-19.76-19.76 15.38-19.77-15.38 15.38 19.76-15.38 19.76 19.77-15.38z" fill="#fff"/><path d="m193.05 80.92-13.54 34.85 21.69-30.46 34.84 13.54-30.45-21.68 13.54-34.85-21.69 30.46-34.84-13.54 30.45 21.68z" fill="#fff"/><path d="m104.06 234.71-22.09 24.58 27.45-18.4 24.58 22.1-18.4-27.46 22.1-24.58-27.46 18.4-24.58-22.09 18.4 27.45z" fill="#fff"/>'
                )
            );
        }
        if (id == SILVER) {
            render = string(
                abi.encodePacked(
                    '<path d="m176.39 204.56c-3.83 0-6.94-3.11-6.94-6.94-1.36-75.58-113.66-75.54-115 0 0.17 8.99-14.03 9.01-13.87 0 1.69-93.81 141.08-93.77 142.75 0 0 3.83-3.11 6.94-6.94 6.94z" fill="#FFA4BC"/><path d="M172.34 0L112.12 0.220001L51.38 0L0.169983 50.31L0 50.53L112.34 198L223.33 50.65L172.34 0Z" fill="#36C1E2"/><path d="m51.38 0-51.21 50.31 60.96 1.13-9.75-51.44z" fill="#fff" opacity=".5"/><path d="m51.38 0 6.49 47.93-51.02 2.72 52 0.76 29.04 76.48-26.2-76.56h54.62l-52.07-2.55 30.54-30.77-33.87 29.32-9.53-47.33z" fill="#fff"/>',
                    '<path d="m51.38 0 60.74 0.22-50.88 50.88-9.86-51.1z" fill="#fff" opacity=".75"/><path d="m161.07 50.53-48.95-50.31-50.99 51.22 99.94-0.91z" fill="#fff" opacity=".95"/><path d="m161.07 50.53-48.95-50.31 60.22-0.22-11.27 50.53z" fill="#fff" opacity=".6"/><path d="m161.07 50.53 62.26 0.12-50.99-50.65-11.27 50.53z" fill="#fff" opacity=".4"/><path d="M161.07 50.53L223.33 50.65L112.34 198L161.07 50.53Z" fill="#fff" opacity=".6"/>',
                    '<path d="m161.07 50.53-99.83 0.91 51.1 146.56 48.73-147.47z" fill="#fff" opacity=".85"/><path d="m80.05 110.07c-7.56-8.94-29.47 19.82-47.65 15.2-17.03-3.43-8.18-24.51 0.95-30.89l-8.5-11.12c-22.9 16.09-21.54 56.26 10.36 56.08 16.75-0.92 53-15.03 44.84-29.27z" fill="#FFA4BC"/><path d="m33.36 94.39-7.03-9.2c-8.96 8.4-7.64 26.97-2.53 33.8-4.56-9.28 3.78-19.19 9.56-24.6z" fill="#E08CA6"/><path d="m143.89 109.79c7.56-8.94 29.47 19.82 47.65 15.2 17.03-3.43 8.18-24.51-0.95-30.89l8.5-11.12c22.9 16.09 21.54 56.26-10.36 56.08-16.74-0.92-52.99-15.03-44.84-29.27z" fill="#FFA4BC"/><path d="m190.59 94.1 7.03-9.2c8.96 8.4 7.64 26.97 2.53 33.8 4.56-9.27-3.79-19.18-9.56-24.6z" fill="#E08CA6"/>',
                    '<path d="m160.11 106.3c-15.92-5.51 2.71-44.12 15.49-31.19 3.93 3.98 1.96 12.32 0.29 16.84-3.26 8.86-7.59 17.19-15.78 14.35z" fill="#fff"/><path d="m173.67 84.76c-1.04-4.68-7.18-6.97-9.71-3.71 2.71 1 4.34 3.45 3.69 5.66-0.69 2.33-3.67 3.5-6.65 2.62-0.39-0.12-0.77-0.26-1.12-0.44-1.89 4.97-2.21 10.23 4.06 11.79 7.21 1.79 10.56-12.19 9.73-15.92z" fill="#330017"/><path d="m63.28 106.3c15.92-5.51-2.71-44.12-15.49-31.19-3.93 3.98-1.9599 12.32-0.2899 16.84 3.26 8.86 7.5899 17.19 15.78 14.35z" fill="#fff"/><path d="m50.15 84.64c0.96-4.65 6.87-6.88 9.34-3.6-2.6 0.97-4.16 3.4-3.51 5.6 0.69 2.33 3.58 3.53 6.45 2.67 0.38-0.11 0.74-0.26 1.08-0.42 1.87 4.97 2.24 10.23-3.8 11.72-6.94 1.71-10.32-12.27-9.56-15.97z" fill="#330017"/><path d="m111.29 112.31c18.016 0 32.62-8.757 32.62-19.56 0-10.803-14.604-19.56-32.62-19.56-18.016 0-32.62 8.7573-32.62 19.56 0 10.803 14.604 19.56 32.62 19.56z" fill="#FFA4BC"/>',
                    '<path d="m111.29 82.04c5.589 0 10.12-2.2789 10.12-5.09s-4.531-5.09-10.12-5.09-10.12 2.2789-10.12 5.09 4.531 5.09 10.12 5.09z" fill="#330017"/><path d="m126.93 90.66c-0.05 2.88-2.04 5.18-4.36 6.66-3.19 2.04-7.04 2.89-10.8 2.89s-7.6-0.85-10.8-2.89c-2.33-1.49-4.31-3.78-4.36-6.66-0.04-2.23-3.51-2.24-3.47 0 0.12 6.58 6.34 10.74 12.13 12.22 6.88 1.76 15.05 0.79 20.69-3.7601 2.59-2.09 4.37-5.0799 4.43-8.4499 0.05-2.24-3.42-2.24-3.46-0.01z" fill="#330017"/><path d="m169.45 30.38 16.12 12.55-12.55-16.12 12.55-16.12-16.12 12.54-16.12-12.54 12.54 16.12-12.54 16.12 16.12-12.55z" fill="#fff"/><path d="m87.69 139.96-0.05 20.43 5.07-19.79 20.42 0.05-19.79-5.07 0.05-20.42-5.06 19.79-20.43-0.05 19.79 5.06z" fill="#fff"/><path d="m53.27 54.22-0.04 20.43 5.06-19.79 20.43 0.04-19.79-5.06 0.05-20.43-5.07 19.79-20.42-0.04 19.78 5.06z" fill="#fff"/>'
                )
            );
        }
        if (id == ELIXIR) {
            render = string(
                abi.encodePacked(
                    '<path d="M176.947 182.265C173.117 182.265 170.016 179.158 170.016 175.333C170.016 140.592 156.467 125.097 126.092 125.097C95.7121 125.097 82.1693 140.592 82.1693 175.333C82.1693 179.164 79.0627 182.265 75.2375 182.265C71.4123 182.265 68.3058 179.158 68.3058 175.333C68.3058 155.981 72.1586 141.404 80.0798 130.769C89.7367 117.806 105.22 111.234 126.098 111.234C146.976 111.234 162.465 117.806 172.116 130.769C180.037 141.404 183.89 155.981 183.89 175.333C183.885 179.164 180.778 182.265 176.947 182.265Z" fill="black"/><path d="M194.1 0L126.275 0.204522L57.875 0L0.193473 44.6362L0 44.8352L126.529 200.23L251.522 44.9402L194.1 0Z" fill="#58A316"/><path opacity="0.5" d="M57.8751 0L0.193481 44.6362L68.8475 45.6422L57.8751 0Z" fill="white"/><path d="M57.875 0L65.1771 42.5246L7.72217 44.9402L66.2827 45.6146L98.9901 113.462L69.4887 45.5428H130.995L72.3576 43.2819L106.751 15.9861L68.6043 41.9884L57.875 0Z" fill="white"/>',
                    '<path opacity="0.75" d="M57.875 0L126.275 0.204522L68.9746 45.3382L57.875 0Z" fill="white"/><path opacity="0.95" d="M181.403 44.8352L126.275 0.204521L68.8475 45.6422L181.403 44.8352Z" fill="white"/><path opacity="0.6" d="M181.403 44.8352L126.275 0.204522L194.1 0L181.403 44.8352Z" fill="white"/><path opacity="0.4" d="M181.403 44.8352L251.522 44.9402L194.1 0L181.403 44.8352Z" fill="white"/><path opacity="0.6" d="M181.403 44.8352L251.522 44.9402L126.529 200.23L181.403 44.8352Z" fill="white"/>',
                    '<path opacity="0.85" d="M181.403 44.8352L68.9747 45.6422L126.529 200.23L181.403 44.8352Z" fill="white"/><path d="M90.1624 97.6579C81.6497 89.7257 56.9741 115.242 36.505 111.146C17.3239 108.1 27.2958 89.3996 37.5773 83.7392L28.0089 73.8777C2.21663 88.1503 3.74781 123.787 39.6779 123.627C58.5218 122.809 99.3494 110.289 90.1624 97.6579Z" fill="black"/><path d="M162.061 97.4092C170.574 89.4769 195.25 114.993 215.719 110.897C234.9 107.851 224.928 89.1508 214.646 83.4904L224.215 73.629C250.007 87.9015 248.476 123.539 212.546 123.378C193.696 122.555 152.874 110.034 162.061 97.4092Z" fill="black"/><path d="M207.67 73.817C210.583 99.4434 161.249 90.7207 167.578 66.1279C169.524 58.5605 179.087 57.4771 184.581 57.7534C195.366 58.2952 206.172 60.6389 207.67 73.817Z" fill="white"/><path d="M178.451 64.3756C174.244 68.0903 175.189 78.0512 179.871 80.1738C179.446 75.7848 181.065 72.2637 183.663 72.1697C186.405 72.0702 189.197 75.8235 189.893 80.5552C189.987 81.1798 190.031 81.7879 190.048 82.3794C196.117 82.7608 201.667 80.7487 199.893 70.9425C197.853 59.6605 181.806 61.4128 178.451 64.3756Z" fill="#330017"/>',
                    '<path d="M125.335 99.6424C145.627 99.6424 162.078 91.8739 162.078 82.2909C162.078 72.708 145.627 64.9395 125.335 64.9395C105.043 64.9395 88.5924 72.708 88.5924 82.2909C88.5924 91.8739 105.043 99.6424 125.335 99.6424Z" fill="#58A316"/><g opacity="0.4"><path opacity="0.4" d="M97.5253 70.9591C81.6442 89.792 169.032 89.792 153.151 70.9591C140.171 63.0821 110.499 63.0821 97.5253 70.9591Z" fill="white"/></g><path d="M138.867 78.1673C138.85 80.5221 137.944 82.8824 136.385 84.6844C134.633 86.7131 132.339 88.1171 129.774 88.891C124.462 90.494 118.199 89.3609 114.263 85.4638C112.262 83.4794 111.074 80.909 111.052 78.1673C111.035 76.1883 107.962 76.1828 107.973 78.1673C108.028 84.7618 113.097 89.9026 119.139 91.7986C125.534 93.8051 133.185 92.3569 137.96 87.5091C140.426 85.005 141.918 81.6884 141.946 78.1617C141.963 76.1883 138.884 76.1828 138.867 78.1673Z" fill="#330017"/>',
                    '<path d="M190.501 71.7938C192.223 71.7938 193.619 70.4426 193.619 68.7757C193.619 67.1088 192.223 65.7576 190.501 65.7576C188.779 65.7576 187.384 67.1088 187.384 68.7757C187.384 70.4426 188.779 71.7938 190.501 71.7938Z" fill="white"/><path d="M44.0337 73.817C41.1206 99.4434 90.4553 90.7207 84.1261 66.1279C82.1804 58.5605 72.6174 57.4771 67.1229 57.7534C56.3383 58.2952 45.5317 60.6389 44.0337 73.817Z" fill="white"/><path d="M73.2531 64.3756C77.4597 68.0903 76.5144 78.0512 71.8325 80.1738C72.2581 75.7848 70.6385 72.2637 68.0405 72.1697C65.2987 72.0702 62.5072 75.8235 61.8107 80.5552C61.7168 81.1798 61.6726 81.7879 61.656 82.3794C55.5866 82.7608 50.0367 80.7487 51.8111 70.9425C53.8453 59.6605 69.8978 61.4128 73.2531 64.3756Z" fill="#330017"/><path d="M61.1972 71.7938C62.919 71.7938 64.3148 70.4426 64.3148 68.7757C64.3148 67.1088 62.919 65.7576 61.1972 65.7576C59.4754 65.7576 58.0796 67.1088 58.0796 68.7757C58.0796 70.4426 59.4754 71.7938 61.1972 71.7938Z" fill="white"/><path d="M125.335 72.7888C131.633 72.7888 136.739 70.7644 136.739 68.2671C136.739 65.7699 131.633 63.7455 125.335 63.7455C119.037 63.7455 113.932 65.7699 113.932 68.2671C113.932 70.7644 119.037 72.7888 125.335 72.7888Z" fill="#330017"/>',
                    '<path d="M36.1898 46.8639L50.4955 57.9911L39.3627 43.691L50.4955 29.3908L36.1898 40.5181L21.8896 29.3908L33.0224 43.691L21.8896 57.9911L36.1898 46.8639Z" fill="white"/><path d="M187.168 27.0857L195.128 40.5125L190.711 25.5435L204.132 17.5781L189.163 22.0003L181.204 8.57901L185.626 23.548L172.199 31.5079L187.168 27.0857Z" fill="white"/>'
                )
            );
        }
        return render;
    }
}
