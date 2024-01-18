## Tasks

```bash
[{ "name": "Solidity Contract", "id": "0", "description": "solidity", "fee": "3000000000000000000", "intervalInDays": "7", "available": true, "pastBuyers": [], "comment": [] },{ "name": "Rust Contract", "id": "1", "description": "", "fee": "2100000000000000000", "intervalInDays": "5", "available": true, "pastBuyers": [], "comment": [] },{ "name": "Web3 Dapp Web/Mobile - Simple", "id": "2", "description": "", "fee": "1500000000000000000", "intervalInDays": "7", "available": true, "pastBuyers": [], "comment": [] },{ "name": "Web3 Dapp Web/Mobile - Advanced", "id": "3", "description": "", "fee": "1800000000000000000", "intervalInDays": "6", "available": true, "pastBuyers": [], "comment": [] },{ "name": "Web2 Backend: Rust/Go/Python/Js", "id": "4", "description": "", "fee": "1500000000000000000", "intervalInDays": "8", "available": true, "pastBuyers": [], "comment": [] },{ "name": "Web2 Full Stack Web/Mobile App", "id": "5", "description": "", "fee": "4000000000000000000", "intervalInDays": "16", "available": true, "pastBuyers": [], "comment": [] },{ "name": "Web3 Dapp Web/Mobile + Contract", "id": "6", "description": "", "fee": "5000000000000000000", "intervalInDays": "21", "available": true, "pastBuyers": [], "comment": [] },{ "name": "Web3 Dapp Web + Mobile + Contract", "id": "7", "description": "", "fee": "8000000000000000000", "intervalInDays": "31", "available": true, "pastBuyers": [], "comment": [] }]
```

## Getting Started

Create a project using this example:

```bash
npx thirdweb create --contract --template hardhat-javascript-starter
```

You can start editing the page by modifying `contracts/Contract.sol`.

To add functionality to your contracts, you can use the `@thirdweb-dev/contracts` package which provides base contracts and extensions to inherit. The package is already installed with this project. Head to our [Contracts Extensions Docs](https://portal.thirdweb.com/contractkit) to learn more.

## Building the project

After any changes to the contract, run:

```bash
npm run build
# or
yarn build
```

to compile your contracts. This will also detect the [Contracts Extensions Docs](https://portal.thirdweb.com/contractkit) detected on your contract.

## Deploying Contracts

When you're ready to deploy your contracts, just run one of the following command to deploy you're contracts:

```bash
npm run deploy
# or
yarn deploy
```

## Releasing Contracts

If you want to release a version of your contracts publicly, you can use one of the followings command:

```bash
npm run release
# or
yarn release
```

## Join our Discord!

For any questions, suggestions, join our discord at [https://discord.gg/thirdweb](https://discord.gg/thirdweb).
