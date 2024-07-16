// SPDX-License-Identifier: CC0-1.0
pragma solidity ^0.8.0;

/**
 * @title The interface for ERC173 Ownable standard
 * @dev ERC173 provides basic authorization control functions, this simplifies
 *      the implementation of "user permissions".
 */
interface IERC173 {
    /**
     * @notice The ownership of the contract was transferred.
     * @dev MUST be emitted when the ownership is transferred.
     * @param previousOwner The address of the previous owner.
     * @param newOwner The address of the new owner.
     */
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @notice Get the address of the owner.
     * @dev This function MUST NOT revert.
     * @return The address of the owner.
     */
    function owner() external view returns (address);

    /**
     * @notice Set the address of the new owner of the contract.
     * @dev Set `newOwner` as owner of the contract.
     *      MUST revert if the caller is not the current owner.
     *      MUST emit a `OwnershipTransferred` event.
     * @param newOwner The address of the new owner.
     */
    function transferOwnership(address newOwner) external;

    /**
     * @notice Set the address(0) as a new owner of the contract.
     * @dev Set owner to address(0) to renounce any ownership.
     *      MUST revert if the caller is not the current owner.
     *      MUST emit a `OwnershipTransferred` event.
     */
    function renounceOwnership() external;
}
