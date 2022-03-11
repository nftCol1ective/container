pragma solidity >=0.8.0 <0.9.0;
//SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

import 'base64-sol/base64.sol';
import "hardhat/console.sol";
import "./TreasureEntities.sol";
import "../Libraries/ToUint.sol";


contract LoogieTank is ERC721Enumerable, Ownable, ERC1155Holder {

    using Strings for uint256;
    using Strings for uint8;
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIds;

    bytes4 private constant INTERFACE_ERC721 = 0x80ac58cd;

    // uint256 constant public price = 5000000000000000; // 0.005 eth
    uint256 constant public price = 0; // 0.005 eth

    struct Entity {
        uint256 blockAdded;
        uint256 id;
        address addr;
        uint8 tokenType;    // ERC721 (0) or 1155 (1)
        uint8 x;
        uint8 y;
        uint8 scale;
        int8 dx;
        int8 dy;
    }

    mapping( uint256 => Entity[]) public EntitiesByTankId;
    mapping( address => uint256[]) public tanksByOwner;
    mapping( uint256 => address) public itemsetByTankId;

    event ContainerMinted(uint256 id);
    event EntityReceived(uint256 id, uint256 value);


    constructor() ERC721("Tank", "TANK") {}

    function setEntityContractAddress(uint256 tankId, address _entitiesContractAddress) public {
        itemsetByTankId[tankId] = _entitiesContractAddress;
    }

    function setupNewContainer(uint256 containerType, uint256[] memory items, uint256[] memory amount) public returns (uint256) {
        uint256 id = mintItem();

        TreasureEntities itemTokens = new TreasureEntities('');
        itemTokens.setApprovalForAll(msg.sender, true);

        for(uint256 index = 0; index < items.length; index++) {
            itemTokens.mint(address(this), items[index], amount[index], bytes(abi.encodePacked(id)));
        }

        itemsetByTankId[id] = address(itemTokens);

        return id;
    }

    function mintItem() public returns (uint256) {
        // require(msg.value >= price, "Sent eth not enough");

        _tokenIds.increment();
        uint256 id = _tokenIds.current();
        _mint(msg.sender, id);

        tanksByOwner[msg.sender].push(id);
        emit ContainerMinted(id);

        return id;
    }

    function ownerTankIds() external view returns (uint256[] memory)  {
        return tanksByOwner[msg.sender];
    }

    function ownerTankUris() external view returns (string[] memory) {
        uint256 tankCount = tanksByOwner[msg.sender].length;

        string[] memory result = new string[](tankCount);
        for(uint256 index = 0; index < tankCount; index++) {
            result[index] = tokenURI(tanksByOwner[msg.sender][index]);
        }

        return result;
    }

    function returnAll(uint256 _id) external {
        require(msg.sender == ownerOf(_id), "only tank owner can return the NFTs");
        for (uint256 i = 0; i < EntitiesByTankId[_id].length; i++) {
            // if transferFrom fails, it will ignore and continue
//            try SvgNftApi(EntitiesByTankId[_id][i].addr).transferFrom(address(this), ownerOf(_id), EntitiesByTankId[_id][i].id) {}
//            catch {}
        }

        delete EntitiesByTankId[_id];
    }

    function tokenURI(uint256 id) public view override returns (string memory) {
        require(_exists(id), "token does not exist");

        string memory _name = string(abi.encodePacked('Loogie Tank #', id.toString()));
        string memory description = string(abi.encodePacked('Loogie Tank'));
        string memory image = Base64.encode(bytes(generateSVGofTokenById(id)));

        return string(abi.encodePacked(
                'data:application/json;base64,',
                Base64.encode(
                    bytes(
                        abi.encodePacked(
                            '{"',
                                'name":"', _name, '",',
                                '"description":"', description, '",',
                                '"image": "data:image/svg+xml;base64,', image, '",',
                                '"tokenid":"', Strings.toString(id),
                            '"}'
                        )
                    )
                )
            ));
    }

    function generateSVGofTokenById(uint256 id) internal view returns (string memory) {
        string memory svg = string(abi.encodePacked(
                '<svg width="310" height="310" xmlns="http://www.w3.org/2000/svg">',
                renderTokenById(id),
                '</svg>'
            ));

        return svg;
    }

    // Visibility is `public` to enable it being called by other contracts for composition.
    function renderTokenById(uint256 id) public view returns (string memory) {
    string memory render = string(abi.encodePacked(
                '<rect x="0" y="0" width="310" height="310" stroke="black" fill="#8FB9EB" stroke-width="5"/>',
                renderComponent(id)
            ));
        return render;
    }

    function renderComponent(uint256 _id) internal view returns (string memory) {
        string memory svg = "";

        for (uint8 i = 0; i < EntitiesByTankId[_id].length; i++) {
            Entity memory c = EntitiesByTankId[_id][i];
            uint8 blocksTravelled = uint8((block.number - c.blockAdded) % 256);
            uint8 newX;
            uint8 newY;

            newX = newPos(c.dx, blocksTravelled, c.x);
            newY = newPos(c.dy, blocksTravelled, c.y);

            svg = string(abi.encodePacked(
                    svg,
                    '<g>',
                    '<animateTransform attributeName="transform" dur="1500s" fill="freeze" type="translate" additive="sum" ',
                    'values="', newX.toString(), ' ', newY.toString(), ';'));

            for (uint8 j = 0; j < 100; j++) {
                newX = newPos(c.dx, 1, newX);
                newY = newPos(c.dy, 1, newY);

                svg = string(abi.encodePacked(
                        svg,
                        newX.toString(), ' ', newY.toString(), ';'));
            }

            uint8 scale = c.scale;
            string memory scaleString = "";
            if (scale != 0) {
                scaleString = string(abi.encodePacked('values="0.', scale.toString(), ' 0.', scale.toString(), '"'));
            }

            string memory _svg;

            try TreasureEntities(itemsetByTankId[_id]).renderTokenById(0) returns (string memory __svg) {
                _svg = __svg;
            } catch {return "";}

            svg = string(abi.encodePacked(
                    svg,
                    '"/>',
                    '<animateTransform attributeName="transform" type="scale" additive="sum" ', scaleString, '/>',
                    _svg,
                    '</g>'));
        }

        return svg;
    }

    function newPos(int8 speed, uint8 blocksTraveled, uint8 initPos) internal pure returns (uint8) {
        uint8 traveled;
        uint8 start;

        if (speed >= 0) {
        unchecked {
            traveled = blocksTraveled * uint8(speed);
            start = initPos + traveled;
        }
            return start;
        } else {
        unchecked {
            traveled = blocksTraveled * uint8(- speed);
            start = initPos - traveled;
        }
            return start;
        }
    }

    function sendEthToOwner() external {
        (bool success,) = owner().call{value : address(this).balance}("");
        require(success, "could not send ether");
    }

    // Receive new NFT
    function transferNFT(address nftAddr, uint256 tokenId, uint256 tankId, uint8 scale) external {
        require(ERC721(nftAddr).ownerOf(tokenId) == msg.sender, "you need to own the NFT");
        require(ownerOf(tankId) == msg.sender, "you need to own the tank");
        require(nftAddr != address(this), "nice try!");
        require(EntitiesByTankId[tankId].length < 256, "tank has reached the max limit of 255 components");

        ERC721(nftAddr).transferFrom(msg.sender, address(this), tokenId);
        require(ERC721(nftAddr).ownerOf(tokenId) == address(this), "NFT not transferred");

        registerToken(nftAddr, tankId, tokenId, 1, 0);
    }

    function onERC1155Received(address operator, address from, uint256 id, uint256 value, bytes memory data)
            public override returns (bytes4) {
        console.log('received token with id ', id);

        registerToken(from, ToUint.bytesToUint(data), id, value, 1);
        return super.onERC1155Received(operator, from, id, value, data);
    }

    function registerToken(address from, uint tankId, uint256 tokenId, uint256 value, uint8 tokenType) internal {
        bytes32 randish = keccak256(abi.encodePacked(blockhash(block.number - 1), msg.sender, address(this), tokenId, tankId));
        EntitiesByTankId[tankId].push(Entity(block.number, tokenId, from, tokenType,
                uint8(randish[0]), uint8(randish[1]), 1, int8(uint8(randish[2])), int8(uint8(randish[3]))));

        emit EntityReceived(tokenId, value);
    }

    // Allows to extend both ERC721 and ERC1155Holder contracts from OpenZeppelin
    function supportsInterface(bytes4 interfaceId) public view override(ERC721Enumerable, ERC1155Receiver) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
