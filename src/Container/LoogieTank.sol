pragma solidity >=0.8.0 <0.9.0;
//SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

import 'base64-sol/base64.sol';
import "hardhat/console.sol";


interface SvgNftApi {
    function renderTokenById(uint256 id) external view returns (string memory);

    function transferFrom(address from, address to, uint256 id) external;
}

contract LoogieTank is ERC721Enumerable, Ownable, ERC1155Holder {

    using Strings for uint256;
    using Strings for uint8;
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIds;

    bytes4 private constant INTERFACE_ERC721 = 0x80ac58cd;

    // uint256 constant public price = 5000000000000000; // 0.005 eth
    uint256 constant public price = 0; // 0.005 eth

    struct Component {
        uint256 blockAdded;
        uint256 id;   // token id of the ERC721 contract at `addr`
        address addr; // address of the ERC721 contract
        uint8 x;
        uint8 y;
        uint8 scale;
        int8 dx;
        int8 dy;
    }

    mapping(uint256 => Component[]) public componentsByTankId;
    mapping(address => uint256[]) public tanksByOwner;

    event ContainerMinted(uint256 id);


    constructor() ERC721("Tank", "TANK") {
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
        for (uint256 i = 0; i < componentsByTankId[_id].length; i++) {
            // if transferFrom fails, it will ignore and continue
            try SvgNftApi(componentsByTankId[_id][i].addr).transferFrom(address(this), ownerOf(_id), componentsByTankId[_id][i].id) {}
            catch {}
        }

        delete componentsByTankId[_id];
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

        for (uint8 i = 0; i < componentsByTankId[_id].length; i++) {
            Component memory c = componentsByTankId[_id][i];
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
            try SvgNftApi(c.addr).renderTokenById(c.id) returns (string memory __svg) {
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
        require(componentsByTankId[tankId].length < 256, "tank has reached the max limit of 255 components");

        ERC721(nftAddr).transferFrom(msg.sender, address(this), tokenId);
        require(ERC721(nftAddr).ownerOf(tokenId) == address(this), "NFT not transferred");

        bytes32 randish = keccak256(abi.encodePacked(blockhash(block.number - 1), msg.sender, address(this), tokenId, tankId));
        componentsByTankId[tankId].push(Component(
                block.number,
                tokenId,
                nftAddr,
                uint8(randish[0]),
                uint8(randish[1]),
                scale,
                int8(uint8(randish[2])),
                int8(uint8(randish[3]))));
    }

    function onERC1155Received(address operator, address from, uint256 id, uint256 value, bytes memory data)
            public override returns (bytes4) {
        // transferNFT(from, id, 0, 1);
        console.log('received');
        return super.onERC1155Received(operator, from, id, value, datax);
    }

    // Allows to extend both ERC721 and ERC1155Holder contracts from OpenZeppelin
    function supportsInterface(bytes4 interfaceId) public view override(ERC721Enumerable, ERC1155Receiver) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
