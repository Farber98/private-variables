// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

/*
# Storage
- 2 ** 256 slots
- 32 bytes for each slot
*/

contract Vault {
    uint256 public count = 123;
    address public owner = msg.sender;
    bool public isTrue = true;
    uint16 public u16 = 31;
    bytes32 private password; // Slot 2
    uint256 public constant someConst = 123;
    bytes32[3] public data;

    struct User {
        uint256 id;
        bytes32 password;
    }

    User[] private users; // Starting at slot 6

    // Starting at slot 7
    mapping(uint256 => User) private idToUser;

    constructor(bytes32 _password) {
        password = _password;
    }

    function addUser(bytes32 _password) public {
        User memory user = User({id: users.length, password: _password});

        users.push(user);
        idToUser[user.id] = user;
    }
}
