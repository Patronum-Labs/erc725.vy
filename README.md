# @patronumlabs/erc725.vy

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/license/mit)

This repo is an implementation of the ERC725 standard in Vyper. It contains ERC725Y and ERC725X:

- ERC725Y represents a generic key-value store that can be used to store arbitrary data for smart contracts. This can include identity information, metadata, or any other type of data that needs to be associated with a smart contract.

- ERC725X represents a generic execute function that allows a smart contract to execute arbitrary transactions. This can be used to implement proxy functionality, allowing the contract to interact with other contracts or perform complex operations.

> This implementation is not audited. Please use at your own risk!

## Usage

* Refer to [Vyper documentation](https://docs.vyperlang.org/en/stable/) to install Vyper.
* Refer to [Foundry documentation](https://book.getfoundry.sh/) to install Foundry.

After installation, you can build and test the contracts:

### Build Vyper contracts

```bash
npm run build
```

### Test in Foundry

```bash
npm run test
```

## Contributing
Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
