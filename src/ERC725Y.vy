# pragma version ~=0.4.0
"""
@title ERC725Y Implementation with Ownable and ERC165
@license MIT
@author PatronumLabs YamenMerhi
@notice This contract implements the ERC725Y standard with ownership control and interface detection.
"""

from vyper.interfaces import ERC165

implements: ERC165

# Events
event OwnershipTransferred:
    previousOwner: indexed(address)
    newOwner: indexed(address)

event DataChanged:
    dataKey: indexed(bytes32)
    dataValue: Bytes[1024]

# Storage variables
owner: public(address)
store: public(HashMap[bytes32, Bytes[1024]])

# Constants
ERC725Y_INTERFACE_ID: constant(bytes4) = 0x629aa694
ERC165_INTERFACE_ID: constant(bytes4) = 0x01ffc9a7

# @dev Stores the 1-byte upper bound for the dynamic arrays.
_DYNARRAY_BOUND: constant(uint8) = max_value(uint8)

@external
def __init__(_owner: address):
    """
    @dev Initializes the contract, setting the provided address as the initial owner.
    @param _owner The address to be set as the initial owner of the contract.
    """
    self._transfer_ownership(_owner)

# ERC165 function
@external
@view
def supportsInterface(interfaceId: bytes4) -> bool:
    """
    @dev See {IERC165-supportsInterface}.
    @param interfaceId The interface identifier, as specified in ERC-165.
    @return bool True if the contract supports the interface, False otherwise.
    """
    return interfaceId in [ERC725Y_INTERFACE_ID, ERC165_INTERFACE_ID]

# ERC173 functions
@external
def transferOwnership(new_owner: address):
    """
    @dev Transfers ownership of the contract to a new account (`new_owner`).
    @notice Can only be called by the current owner.
    @param new_owner The address to transfer ownership to.
    """
    self._check_owner()
    assert new_owner != empty(address), "ERC725Y: new owner is the zero address"
    self._transfer_ownership(new_owner)

@external
def renounceOwnership():
    """
    @dev Leaves the contract without owner. It will not be possible to call
         `setData` and other owner-restricted functions anymore.
    @notice Can only be called by the current owner.
    """
    self._check_owner()
    self._transfer_ownership(empty(address))

# ERC725Y functions
@external
@view
def getData(dataKey: bytes32) -> Bytes[1024]:
    """
    @dev Gets data at a given `dataKey`.
    @param dataKey The key which value to retrieve.
    @return The data stored at the given `dataKey`.
    """
    return self._getData(dataKey)

@external
@payable
def setData(dataKey: bytes32, dataValue: Bytes[1024]):
    """
    @dev Sets data at a given `dataKey`.
    @notice Only callable by the owner.
    @param dataKey The key to set the value at.
    @param dataValue The value to set.
    """
    self._check_owner()
    self._setData(dataKey, dataValue)

@external
@view
def getDataBatch(dataKeys: DynArray[bytes32, _DYNARRAY_BOUND]) -> DynArray[Bytes[1024], _DYNARRAY_BOUND]:
    """
    @dev Gets data for multiple keys.
    @param dataKeys The array of keys which values to retrieve.
    @return An array of the values for each key.
    """
    values: DynArray[Bytes[1024], _DYNARRAY_BOUND] = []
    for key in dataKeys:
        values.append(self._getData(key))
    return values

@external
@payable
def setDataBatch(dataKeys: DynArray[bytes32, _DYNARRAY_BOUND], dataValues: DynArray[Bytes[1024], _DYNARRAY_BOUND]):
    """
    @dev Sets data for multiple keys.
    @notice Only callable by the owner.
    @param dataKeys The array of keys to set values for.
    @param dataValues The array of values to set.
    """
    self._check_owner()
    assert len(dataKeys) == len(dataValues), "ERC725Y: keys and values length mismatch"
    assert len(dataKeys) > 0, "ERC725Y: empty arrays"

    for i in range(256): 
        if i >= len(dataKeys):
            break
        self._setData(dataKeys[i], dataValues[i])

@internal
def _check_owner():
    """
    @dev Throws if called by any account other than the owner.
    """
    assert msg.sender == self.owner, "ERC725Y: caller is not the owner"

@internal
def _transfer_ownership(new_owner: address):
    """
    @dev Transfers ownership of the contract to a new account (`new_owner`).
    @param new_owner The address of the new owner.
    """
    old_owner: address = self.owner
    self.owner = new_owner
    log OwnershipTransferred(old_owner, new_owner)

@internal
@view
def _getData(dataKey: bytes32) -> Bytes[1024]:
    """
    @dev Internal function to retrieve data from storage.
    @param dataKey The key to retrieve data for.
    @return The data stored at the given `dataKey`.
    """
    return self.store[dataKey]

@internal
def _setData(dataKey: bytes32, dataValue: Bytes[1024]):
    """
    @dev Internal function to set data and emit the DataChanged event.
    @param dataKey The key to store data under.
    @param dataValue The data to store.
    """
    self.store[dataKey] = dataValue
    log DataChanged(dataKey, dataValue)