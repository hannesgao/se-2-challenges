// SPDX-License-Identifier: MIT
pragma solidity 0.8.4; //Do not change the solidity version as it negativly impacts submission grading

import "hardhat/console.sol";
import "./ExampleExternalContract.sol";

contract Staker {
	// State variables
	mapping(address => uint256) public balances;
	uint256 public constant threshold = 1 ether;
	uint256 public deadline;
	bool public openForWithdraw = false;
	ExampleExternalContract public exampleExternalContract;

	// Events
	event Stake(address indexed staker, uint256 amount);

	constructor(address exampleExternalContractAddress) {
		exampleExternalContract = ExampleExternalContract(
			exampleExternalContractAddress
		);
    deadline = block.timestamp + 72 hours;
	}

	// Collect funds in a payable `stake()` function and track individual `balances` with a mapping:
	// (Make sure to add a `Stake(address,uint256)` event and emit it for the frontend `All Stakings` tab to display)
	// Stake function to collect ETH and track balances
	function stake() public payable {
		require(block.timestamp < deadline, "Staking period is over");
		balances[msg.sender] += msg.value;
		emit Stake(msg.sender, msg.value);
	}

	// After some `deadline` allow anyone to call an `execute()` function
	// If the deadline has passed and the threshold is met, it should call `exampleExternalContract.complete{value: address(this).balance}()`
	function execute() public notCompleted {
		require(block.timestamp >= deadline, "Deadline not reached yet");
		require(!exampleExternalContract.completed(), "Already completed");

		if (address(this).balance >= threshold) {
			exampleExternalContract.complete{ value: address(this).balance }();
		} else {
			openForWithdraw = true;
		}
	}

	// If the `threshold` was not met, allow everyone to call a `withdraw()` function to withdraw their balance
	function withdraw() public notCompleted {
		require(openForWithdraw, "Withdrawals are not open");
		require(balances[msg.sender] > 0, "No balance to withdraw");

		uint256 amount = balances[msg.sender];
		balances[msg.sender] = 0;
		(bool success, ) = msg.sender.call{ value: amount }("");
		require(success, "Withdraw failed");
	}

	// Add a `timeLeft()` view function that returns the time left before the deadline for the frontend
	function timeLeft() public view returns (uint256) {
		if (block.timestamp >= deadline) {
			return 0;
		} else {
			return deadline - block.timestamp;
		}
	}

	// Add the `receive()` special function that receives eth and calls stake()
	receive() external payable {
		stake();
	}

	// Modifier to check if contract is not completed
	modifier notCompleted() {
		require(
			!exampleExternalContract.completed(),
			"Contract already completed"
		);
		_;
	}
}
