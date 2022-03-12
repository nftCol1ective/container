pragma solidity >=0.8.0 <0.9.0;
//SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

import "base64-sol/base64.sol";
import "hardhat/console.sol";
import "./TreasureEntities.sol";

contract LoogieTank is ERC721Enumerable, Ownable, ERC1155Holder {
    using Strings for uint256;
    using Strings for uint8;
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIds;

    bytes4 private constant INTERFACE_ERC721 = 0x80ac58cd;

    // uint256 constant public price = 5000000000000000; // 0.005 eth
    uint256 public constant price = 0; // 0.005 eth

    struct Entity {
        uint256 blockAdded;
        uint256 id;
        address addr;
        uint8 tokenType; // ERC721 (0) or 1155 (1)
        uint8 x;
        uint8 y;
        uint8 scale;
        int8 dx;
        int8 dy;
    }

    string[] containerTypes = ["Gaming", "Membership", "Art", "Ticket", "Ownership", "Avatar", "Collection"];

    mapping(uint256 => Entity[]) public EntitiesByTankId;
    mapping(address => uint256[]) public tanksByOwner;
    mapping(uint256 => address) public itemsetByTankId;

    event ContainerMinted(uint256 id);
    event EntityReceived(uint256 id, uint256 value);

    constructor() ERC721("Tank", "TANK") {}

    function getContainerTypes() external view returns (string[] memory) {
        return containerTypes;
    }

    function setEntityContractAddress(uint256 tankId, address _entitiesContractAddress) public {
        itemsetByTankId[tankId] = _entitiesContractAddress;
    }

    function setupNewContainer(
        uint256 containerType,
        uint256[] memory items,
        uint256[] memory amount,
        address entityContractAddress
    ) public returns (uint256) {
        uint256 id = mintItem();
        console.log('mint id: ', id);

        // TODO: Fails because of size limit. Find a solution
        //       Need to provide an address to an entity contract from client side for now
        //         TreasureEntities itemTokens = new TreasureEntities('');
        //         itemTokens.setApprovalForAll(msg.sender, true);

        setEntityContractAddress(id, entityContractAddress);
        for (uint256 index = 0; index < items.length; index++) {
            // TODO: Mint when deployment above works
            // mint(address(this), items[index], amount[index], bytes(abi.encodePacked(id)));

            // TODO: Fails because item contract is deployed from different address
            //       Need to set approval or role for container contract
            TreasureEntities(itemsetByTankId[id]).safeTransferFrom(
                entityContractAddress, address(this), items[index], amount[index], abi.encode(id));
        }

        return id;
    }

    function mintItem() public returns (uint256) {
        // require(msg.value >= price, "Sent eth not enough");

        uint256 id = _tokenIds.current();
        _mint(msg.sender, id);

        tanksByOwner[msg.sender].push(id);
        emit ContainerMinted(id);

        _tokenIds.increment();
        return id;
    }

    function ownerTankIds() external view returns (uint256[] memory) {
        return tanksByOwner[msg.sender];
    }

    function ownerTankUris() external view returns (string[] memory) {
        uint256 tankCount = tanksByOwner[msg.sender].length;

        string[] memory result = new string[](tankCount);
        for (uint256 index = 0; index < tankCount; index++) {
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

    function tokenURI(uint256 tankId) public view override returns (string memory) {
        require(_exists(tankId), "token does not exist");

        string memory _name = string(abi.encodePacked("Loogie Tank #", tankId.toString()));
        string memory description = string(abi.encodePacked("Loogie Tank"));
        string memory image = Base64.encode(bytes(generateSVGofTokenById(tankId)));

        return
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    Base64.encode(
                        bytes(
                            abi.encodePacked(
                                '{"',
                                'name":"',
                                _name,
                                '",',
                                '"description":"',
                                description,
                                '",',
                                '"image": "data:image/svg+xml;base64,',
                                image,
                                '",',
                                '"tokenid":"',
                                Strings.toString(tankId),
                                '"}'
                            )
                        )
                    )
                )
            );
    }

    function generateSVGofTokenById(uint256 tankId) internal view returns (string memory) {
        string memory svg = string(
            abi.encodePacked(
                '<svg width="512" height="310" xmlns="http://www.w3.org/2000/svg">',
                renderTokenById(tankId),
                "</svg>"
            )
        );

        return svg;
    }

    // Visibility is `public` to enable it being called by other contracts for composition.
    function renderTokenById(uint256 tankId) public view returns (string memory) {
        string memory render = string(
            abi.encodePacked(
                '<path d="M423.067,332.526H69.4a15.564,15.564,0,0,1-15.565-15.565V94.732A15.564,15.564,0,0,1,69.4,79.167H423.065a15.564,15.564,0,0,1,15.565,15.565V316.964A15.561,15.561,0,0,1,423.067,332.526Z" transform="translate(-53.833 -22.096)" fill="#f7cb15"/>',
                '<path d="M406.125,190.262a15.78,15.78,0,0,1,2.706-8.286L421.35,163.5a15.772,15.772,0,0,0-.039-17.752l-12.263-17.923a15.774,15.774,0,0,1-2.742-9.567,15.774,15.774,0,0,0-16.071-16.431l-5.346.106c-.48.01-.96,0-1.44-.036L356.167,99.94a15.787,15.787,0,0,1-7.015-2.223L326.846,84.268A15.785,15.785,0,0,0,313.758,82.8l-21.324,7.038a15.759,15.759,0,0,1-7.266.623l-24.429-3.637a15.749,15.749,0,0,0-7.1.568l-19.428,6.177.776,30.647a1.067,1.067,0,0,1-2.06.418L221.993,96.77l-27.285,3.18a15.6,15.6,0,0,1-2.174.1l-27.15-.6a15.788,15.788,0,0,1-6.675-1.645L136.28,86.655a15.775,15.775,0,0,0-12.613-.628L102.917,93.89a15.792,15.792,0,0,1-9.305.581l-3.287-.8a15.772,15.772,0,0,0-18.4,21.077l1.787,4.568a15.774,15.774,0,0,1,.82,8.628L71.1,146.411l17.871,12.314a1.5,1.5,0,0,1-1.227,2.685l-19.064-4.963c-.029.062-.057.125-.088.184L58.588,176.794a15.776,15.776,0,0,0,1.793,16.841l14.753,18.512A15.766,15.766,0,0,1,78.537,223l-1.484,22.709a15.81,15.81,0,0,1-.97,4.511l-.612,1.634,16.574-.677a1.449,1.449,0,0,1,.61,2.789L71.406,262.7,66.8,274.984a15.773,15.773,0,0,0-.716,8.542l2.573,13.259a15.773,15.773,0,0,0,11.16,12.164l14.444,4.119a15.782,15.782,0,0,0,8.257.106l22.756-5.86a15.784,15.784,0,0,1,9.583.547L155.3,315.7a15.769,15.769,0,0,0,12.9-.719l18.073-9.354a15.834,15.834,0,0,1,4.06-1.44L202.6,279.56a1.144,1.144,0,0,1,2.145.742l-5.134,24.79c.47.2.934.418,1.388.662l17.772,9.585a15.765,15.765,0,0,0,13.6.656l23.534-9.9a15.82,15.82,0,0,1,2.579-.833l27.628-6.356a15.813,15.813,0,0,1,5.653-.259l27.43,3.712a15.757,15.757,0,0,1,2.887.672l26.377,8.825a15.763,15.763,0,0,0,8.063.514l25.366-5.014a15.759,15.759,0,0,1,4.618-.223l6.182.612a15.774,15.774,0,0,0,16.74-19.972l-1.886-6.7a15.834,15.834,0,0,1-.589-4.049l-.42-29.049-.368-8.356-21.7-18.444a2.013,2.013,0,0,1,2.005-3.422l19.044,7.074-.324-7.349c-.018-.418-.021-.838-.005-1.256Z" transform="translate(-48.873 -17.573)" fill="#fede3a"/>',
                renderComponent(tankId)
            )
        );
        return render;
    }

    function renderComponent(uint256 _tankId) internal view returns (string memory) {
        string memory svg = "";

        console.log('component', _tankId);
        console.log('component', EntitiesByTankId[_tankId].length);

        for (uint8 i = 0; i < EntitiesByTankId[_tankId].length; i++) {
            Entity memory c = EntitiesByTankId[_tankId][i];
            uint8 blocksTravelled = uint8((block.number - c.blockAdded) % 256);
            uint8 newX;
            uint8 newY;

            newX = newPos(c.dx, blocksTravelled, c.x);
            newY = newPos(c.dy, blocksTravelled, c.y);

            svg = string(
                abi.encodePacked(
                    svg,
                    "<g>",
                    '<animateTransform attributeName="transform" dur="1500s" fill="freeze" type="translate" additive="sum" ',
                    'values="',
                    newX.toString(),
                    " ",
                    newY.toString(),
                    ";"
                )
            );

            for (uint8 j = 0; j < 100; j++) {
                newX = newPos(c.dx, 1, newX);
                newY = newPos(c.dy, 1, newY);

                svg = string(abi.encodePacked(svg, newX.toString(), " ", newY.toString(), ";"));
            }

            uint8 scale = c.scale;
            string memory scaleString = "";
            if (scale != 0) {
                scaleString = string(abi.encodePacked('values="0.', scale.toString(), " 0.", scale.toString(), '"'));
            }

            string memory _svg;

            console.log('render: ', _tankId);
            try TreasureEntities(itemsetByTankId[0]).renderTokenById(_tankId) returns (string memory __svg) {
                _svg = __svg;
            } catch {
                return "";
            }

            svg = string(
                abi.encodePacked(
                    svg,
                    '"/>',
                    '<animateTransform attributeName="transform" type="scale" additive="sum" ',
                    scaleString,
                    "/>",
                    _svg,
                    "</g>"
                )
            );
        }

        return svg;
    }

    function newPos(
        int8 speed,
        uint8 blocksTraveled,
        uint8 initPos
    ) internal pure returns (uint8) {
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
                traveled = blocksTraveled * uint8(-speed);
                start = initPos - traveled;
            }
            return start;
        }
    }

    function sendEthToOwner() external {
        (bool success, ) = owner().call{value: address(this).balance}("");
        require(success, "could not send ether");
    }

    // Receive new NFT
    function transferNFT(
        address nftAddr,
        uint256 tokenId,
        uint256 tankId,
        uint8 scale
    ) external {
        require(ERC721(nftAddr).ownerOf(tokenId) == msg.sender, "you need to own the NFT");
        require(ownerOf(tankId) == msg.sender, "you need to own the tank");
        require(nftAddr != address(this), "nice try!");
        require(EntitiesByTankId[tankId].length < 256, "tank has reached the max limit of 255 components");

        ERC721(nftAddr).transferFrom(msg.sender, address(this), tokenId);
        require(ERC721(nftAddr).ownerOf(tokenId) == address(this), "NFT not transferred");

        registerToken(nftAddr, tankId, tokenId, 1, 0);
    }

    function onERC1155Received(
        address operator,
        address from,
        uint256 tokenId,
        uint256 value,
        bytes memory data
    ) public override returns (bytes4) {
        console.log('received:', bytesToUint(data));
        registerToken(from, bytesToUint(data), tokenId, value, 1);
        return super.onERC1155Received(operator, from, tokenId, value, data);
    }

    function registerToken(
        address from,
        uint256 tankId,
        uint256 tokenId,
        uint256 value,
        uint8 tokenType
    ) internal {
        bytes32 randish = keccak256(
            abi.encodePacked(blockhash(block.number - 1), msg.sender, address(this), tokenId, tankId)
        );
        EntitiesByTankId[tankId].push(
            Entity(
                block.number,
                tokenId,
                from,
                tokenType,
                uint8(randish[0]),
                uint8(randish[1]),
                1,
                int8(uint8(randish[2])),
                int8(uint8(randish[3]))
            )
        );

        emit EntityReceived(tokenId, value);
    }

    function bytesToUint(bytes memory b) public returns (uint256){
        uint256 number;
        for (uint i = 0; i < b.length; i++) {
            number = number + uint256(uint8(b[i]) * (2 ** (8 * (b.length - (i + 1)))));
        }
        return number;
    }

    // Allows to extend both ERC721 and ERC1155Holder contracts from OpenZeppelin
    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721Enumerable, ERC1155Receiver)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
