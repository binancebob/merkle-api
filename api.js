const express = require('express');
const app = express();
const PORT = 3000;
 
const { MerkleTree } = require('merkletreejs');
const keccak256 = require('keccak256');
 
const addresses = require('./addresses.json');
const hashedAddresses = addresses.map(addr => keccak256(addr));
const merkleTree = new MerkleTree(hashedAddresses, keccak256, { sortPairs: true });
 
app.get('/proof/:address', (req, res) => {
  let hashedAddress = keccak256(req.params.address);
  let proof = merkleTree.getHexProof(hashedAddress);
  res.send(proof);
});
 
app.listen(PORT, () => {
  console.log(`Listening - http://localhost:${PORT}`);
});