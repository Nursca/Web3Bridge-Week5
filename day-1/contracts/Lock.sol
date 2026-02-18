// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

// Uncomment this line to use console.log
// import "hardhat/console.sol";

contract Lock {
    // values types
    // bool keyword;
    // int time;
    // uint age;
    // address owner;
    // bytes1 by;
    // enum status {
    //     Online,
    //     Onsite
    // }

    // //reference types
    // int256[] students;

    // struct Users{
    //     uint8 id;
    // }

    // mapping(uint8 => Users) identifer;
    
    // string my_name_here;

    string name;

    function setName(string memory _name) public {
        name = _name;
    }

    function getName() public view returns (string memory) {
        return name;
    }
}
