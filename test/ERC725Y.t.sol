// SPDX-License-Identifier: MIT
pragma solidity >=0.8.13;

import "forge-std/Test.sol";
import "../lib/utils/VyperDeployer.sol";
import "./interfaces/IERC725Y.sol";

contract ERC725YTest is Test {
    VyperDeployer public vyperDeployer;
    IERC725Y public erc725y;
    address public owner;
    address public nonOwner;

    bytes32 constant TEST_KEY = keccak256("test");
    bytes constant TEST_VALUE = abi.encode("Hello, ERC725Y!");

    event DataChanged(bytes32 indexed dataKey, bytes dataValue);
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    function setUp() public {
        vyperDeployer = new VyperDeployer();
        owner = address(this);
        nonOwner = address(0x1234);
        erc725y = IERC725Y(
            vyperDeployer.deployContract("ERC725Y", abi.encode(owner))
        );
    }

    // ERC165 Tests
    function testSupportsInterface() public view {
        assertTrue(
            erc725y.supportsInterface(0x629aa694),
            "Should support ERC725Y interface"
        );
        assertTrue(
            erc725y.supportsInterface(0x01ffc9a7),
            "Should support ERC165 interface"
        );
        assertFalse(
            erc725y.supportsInterface(0xffffffff),
            "Should not support invalid interface"
        );
    }

    // Ownership Tests
    function testInitialOwnership() public view {
        assertEq(
            erc725y.owner(),
            owner,
            "Initial owner should be set correctly"
        );
    }

    function testTransferOwnership() public {
        erc725y.transferOwnership(nonOwner);
        assertEq(erc725y.owner(), nonOwner, "Ownership should be transferred");
    }

    function testTransferOwnershipNonOwner() public {
        vm.prank(nonOwner);
        vm.expectRevert("ERC725Y: caller is not the owner");
        erc725y.transferOwnership(nonOwner);
    }

    function testRenounceOwnership() public {
        erc725y.renounceOwnership();
        assertEq(erc725y.owner(), address(0), "Ownership should be renounced");
    }

    function testRenounceOwnershipNonOwner() public {
        vm.prank(nonOwner);
        vm.expectRevert("ERC725Y: caller is not the owner");
        erc725y.renounceOwnership();
    }

    // Single Data Operations Tests
    function testSetAndGetData() public {
        assertEq(
            erc725y.getData(TEST_KEY),
            "",
            "Data should be empty before setting"
        );

        erc725y.setData(TEST_KEY, TEST_VALUE);
        assertEq(
            erc725y.getData(TEST_KEY),
            TEST_VALUE,
            "Data should be set and retrieved correctly"
        );
    }

    function testSetDataNonOwner() public {
        vm.prank(nonOwner);
        vm.expectRevert("ERC725Y: caller is not the owner");
        erc725y.setData(TEST_KEY, TEST_VALUE);
    }

    function testGetNonExistentData() public view {
        assertEq(
            erc725y.getData(keccak256("nonexistent")),
            "",
            "Non-existent data should return empty bytes"
        );
    }

    // Batch Data Operations Tests
    function testSetAndGetDataBatch() public {
        bytes32[] memory keys = new bytes32[](3);
        bytes[] memory values = new bytes[](3);

        keys[0] = keccak256("test1");
        keys[1] = keccak256("test2");
        keys[2] = keccak256("test3");

        values[0] = abi.encode("Hello");
        values[1] = abi.encode("ERC725Y");
        values[2] = abi.encode("Batch");

        erc725y.setDataBatch(keys, values);

        bytes[] memory retrievedValues = erc725y.getDataBatch(keys);

        for (uint i = 0; i < keys.length; i++) {
            assertEq(
                retrievedValues[i],
                values[i],
                "Batch data should be set and retrieved correctly"
            );
        }
    }

    function testSetDataBatchNonOwner() public {
        bytes32[] memory keys = new bytes32[](2);
        bytes[] memory values = new bytes[](2);

        vm.prank(nonOwner);
        vm.expectRevert("ERC725Y: caller is not the owner");
        erc725y.setDataBatch(keys, values);
    }

    function testSetDataBatchMismatchedArrays() public {
        bytes32[] memory keys = new bytes32[](2);
        bytes[] memory values = new bytes[](3);

        vm.expectRevert("ERC725Y: keys and values length mismatch");
        erc725y.setDataBatch(keys, values);
    }

    function testGetDataBatchEmptyKeys() public view {
        bytes32[] memory emptyKeys = new bytes32[](0);
        bytes[] memory retrievedValues = erc725y.getDataBatch(emptyKeys);
        assertEq(
            retrievedValues.length,
            0,
            "Empty keys array should return empty values array"
        );
    }

    function testSetAndGetDataBatchLargeArraysBelowLimit() public {
        bytes32[] memory keys = new bytes32[](255);
        bytes[] memory values = new bytes[](255);

        for (uint i = 0; i < 255; i++) {
            keys[i] = keccak256(abi.encodePacked("key", i));
            values[i] = abi.encode(i);
        }

        erc725y.setDataBatch(keys, values);

        bytes[] memory retrievedValues = erc725y.getDataBatch(keys);

        for (uint i = 0; i < keys.length; i++) {
            assertEq(
                retrievedValues[i],
                values[i],
                "Large batch data should be set and retrieved correctly"
            );
        }
    }

    function testSetDataBatchExceedMaxLength() public {
        bytes32[] memory keys = new bytes32[](257);
        bytes[] memory values = new bytes[](257);

        for (uint i = 0; i < 257; i++) {
            keys[i] = keccak256(abi.encodePacked("key", i));
            values[i] = abi.encode(i);
        }

        vm.expectRevert();
        erc725y.setDataBatch(keys, values);
    }

    // Edge Cases and Special Scenarios
    function testSetAndOverwriteData() public {
        bytes memory initialValue = abi.encode("Initial");
        bytes memory newValue = abi.encode("New");

        erc725y.setData(TEST_KEY, initialValue);
        assertEq(
            erc725y.getData(TEST_KEY),
            initialValue,
            "Initial data should be set correctly"
        );

        erc725y.setData(TEST_KEY, newValue);
        assertEq(
            erc725y.getData(TEST_KEY),
            newValue,
            "Data should be overwritten correctly"
        );
    }

    function testSetEmptyValue() public {
        erc725y.setData(TEST_KEY, "");
        assertEq(
            erc725y.getData(TEST_KEY),
            "",
            "Empty value should be set correctly"
        );
    }

    function testSetMaxSizeValue() public {
        bytes memory maxSizeValue = new bytes(1024);
        for (uint i = 0; i < 1024; i++) {
            maxSizeValue[i] = 0xFF;
        }

        erc725y.setData(TEST_KEY, maxSizeValue);
        assertEq(
            erc725y.getData(TEST_KEY),
            maxSizeValue,
            "Max size value should be set correctly"
        );
    }

    function testSetOverMaxSizeValue() public {
        bytes memory overMaxSizeValue = new bytes(1025);
        for (uint i = 0; i < 1025; i++) {
            overMaxSizeValue[i] = 0xFF;
        }

        vm.expectRevert();
        erc725y.setData(TEST_KEY, overMaxSizeValue);
    }

    function testSetDataPayable() public {
        uint256 amount = 1 ether;
        bytes32 key = keccak256("payableTest");
        bytes memory value = abi.encode("Payable Test");

        erc725y.setData{value: amount}(key, value);

        assertEq(
            erc725y.getData(key),
            value,
            "Data should be set correctly when sending value"
        );
        assertEq(
            address(erc725y).balance,
            amount,
            "Contract should receive the sent value"
        );
    }

    function testSetDataBatchPayable() public {
        uint256 amount = 2 ether;
        bytes32[] memory keys = new bytes32[](2);
        bytes[] memory values = new bytes[](2);

        keys[0] = keccak256("payableBatchTest1");
        keys[1] = keccak256("payableBatchTest2");
        values[0] = abi.encode("Payable Batch Test 1");
        values[1] = abi.encode("Payable Batch Test 2");

        erc725y.setDataBatch{value: amount}(keys, values);

        for (uint i = 0; i < keys.length; i++) {
            assertEq(
                erc725y.getData(keys[i]),
                values[i],
                "Batch data should be set correctly when sending value"
            );
        }
        assertEq(
            address(erc725y).balance,
            amount,
            "Contract should receive the sent value for batch operation"
        );
    }
}
