const { MerkleTree } = require('merkletreejs');
const keccak256 = require('keccak256');

let whitelistAddresses = [
    "0xe3b85322CEC21A2aCc51cac241451F54AFB963b2",
    "0xb31415d10dc5072D816076eC5e064209e521cb59",
    "0x84C03972fb9E97d974A4d7780cA2E92c4Ed23F20",
    "0xe434857EFF04e1d16D587738356c9f7B691DC36f",
    "0xCa2506aFC9846ee85250eb81A3b1864c35Fd0Eb1"
]

const leafNodes = whitelistAddresses.map(addr => keccak256(addr));
const merkleTree = new MerkleTree(leafNodes, keccak256, { sortPairs: true });
const rootHash = merkleTree.getHexRoot();

console.log('Whitelist Merkle Tree\n', merkleTree.toString());

console.log (rootHash);