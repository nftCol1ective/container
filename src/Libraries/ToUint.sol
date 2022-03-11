pragma solidity ^0.8.0;

library ToUint {
    function bytesToUint(bytes memory b) public returns (uint256){
        uint256 number;
        for (uint i = 0; i < b.length; i++) {
            number = number + uint256(uint8(b[i]) * (2 ** (8 * (b.length - (i + 1)))));
        }
        return number;
    }
}
