// TEST CONTRACT FOR VOYAGERSGAME
//
// SPDX-License-Identifier: Unlicensed

pragma solidity >=0.8.0;

import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract VoyagersGenesisPass is ERC1155Burnable, ReentrancyGuard, Ownable {
	using SafeMath for uint256;

	string private baseURI;

	uint256 public constant GEN_PASS_FEE = 0.00008 ether;   // set to 0.08888 ETH on finalize
    uint256 public constant PUBLIC_PASS_FEE = 0.00011 ether; // set to 0.1111 ETH on finalize
	uint256 public constant OG_TIME_LIMIT = 1 hours;   // set to 8 hours on finalize

	string public constant name = "VoyagersGame Genesis Pass";
	string public constant symbol = "VGGP";
	address public VAULT = 0x1f6b72ad351A5D2FD73dD243eDb475a837E43026; // set to a trezor wallet on finalize

	uint16[] public supplyCaps = [0, 10];

	bytes32 public ogMerkleRoot;
	uint256 public startTimestamp;
    bool public paused = false;

	mapping(uint8 => uint256) public supplies;

	mapping(address => uint256) public amountPerWallets;

	event SetStartTimestamp(uint256 indexed _timestamp);
	event ClaimGenPassNFT(address indexed _user);




	constructor(
		string memory _baseURI,
		uint256 _startTimestamp,
		bytes32 _ogMerkleRoot
	) ERC1155(_baseURI) {
		baseURI = _baseURI;
		ogMerkleRoot = _ogMerkleRoot;
		startTimestamp = _startTimestamp;

		emit SetStartTimestamp(startTimestamp);
	}

	function claim(bytes32[] calldata merkleProof)
		external
		payable
		nonReentrant
	{
		
		require(
			block.timestamp >= startTimestamp,
			"VGGENPASS: Not started yet"
		);

        require(
			paused == false,
			"VGGENPASS: Minting Paused"
		);

		uint256 timePeriod = block.timestamp - startTimestamp;  

		if (timePeriod <= OG_TIME_LIMIT) {
            require(
			msg.value >= GEN_PASS_FEE,
			"VGGENPASS: Not enough fee"
		    );
            bytes32 node = keccak256(abi.encodePacked(msg.sender));
		    bool isOGVerified = MerkleProof.verify(merkleProof, ogMerkleRoot, node);
			require(isOGVerified, "VGGENPASS: You are not whitelisted, please wait for public mint");
			require(
				amountPerWallets[msg.sender] + 1 <= 1,
				"VGGENPASS: Can't mint more than 1"
			);

			amountPerWallets[msg.sender] += 1;
            _mint(msg.sender, 1, 1, "");
            emit ClaimGenPassNFT(msg.sender);

		} else if (timePeriod >= OG_TIME_LIMIT) {
            require(
			msg.value >= PUBLIC_PASS_FEE,
			"VGGENPASS: Not enough fee"
		    );

            require(
				amountPerWallets[msg.sender] + 1 <= 1,
				"VGGENPASS: Can't mint more than 1"
			);


            amountPerWallets[msg.sender] += 1;
            _mint(msg.sender, 1, 1, "");
            emit ClaimGenPassNFT(msg.sender);
        } 


		
	}

    function _mint(
		address to,
		uint256 id,
		uint256 amount,
		bytes memory data
	) internal override {
		require(
			supplies[uint8(id)] < supplyCaps[uint8(id)],
			"VGGENPASS: Suppy limit was hit"
		);

		supplies[uint8(id)] += amount;
		super._mint(to, id, amount, data);
	}

    function uri(uint256 typeId) public view override returns (string memory) {

		require(bytes(baseURI).length > 0, "VGGENPASS: base URI is not set");

		return string(abi.encodePacked(baseURI));
	}

    function pause(bool _paused) external onlyOwner {
		paused = _paused;
	}

	function setBaseUri(string memory _baseURI) external onlyOwner {
		baseURI = _baseURI;
	}

	function setOgMerkleRoot(bytes32 _ogMerkleRoot) external onlyOwner {
		ogMerkleRoot = _ogMerkleRoot;
	}


	function setStartTimestamp(uint256 _startTimestamp) external onlyOwner {
		startTimestamp = _startTimestamp;

		emit SetStartTimestamp(startTimestamp);
	}



	

	function withdrawAll() external onlyOwner {
		(bool success, ) = payable(VAULT).call{value: address(this).balance}("");

		require(success, "VGGENPASS: Failed to withdraw to the owner");
	}

	function setVault(address _newVaultAddress) external onlyOwner {
		VAULT = _newVaultAddress;
	}

	function withdraw(uint256 _amount) external onlyOwner {
		require(address(VAULT) != address(0), "VGGENPASS: No vault");
		require(payable(VAULT).send(_amount), "VGGENPASS: Withdraw failed");
	}

	

}