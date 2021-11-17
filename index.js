const express = require('express');
const app = express();
const port = process.env.PORT || 3000;
 
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
 
app.listen(port, () => {
  console.log(`Listening - ${port}`);
});

app.use(function(req, res, next) {
  res.header("Access-Control-Allow-Origin", '*');
  res.header("Access-Control-Allow-Credentials", true);
  res.header('Access-Control-Allow-Methods', 'GET,PUT,POST,DELETE,OPTIONS');
  res.header("Access-Control-Allow-Headers", 'Origin,X-Requested-With,Content-Type,Accept,content-type,application/json');
  next();
});