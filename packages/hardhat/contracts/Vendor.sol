pragma solidity 0.8.4; //Do not change the solidity version as it negativly impacts submission grading
// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/access/Ownable.sol";
import "./YourToken.sol";

contract Vendor is Ownable {
	uint256 public constant tokensPerEth = 100;

	event BuyTokens(
		address indexed buyer,
		uint256 amountOfETH,
		uint256 amountOfTokens
	);
	event SellTokens(
		address indexed seller,
		uint256 amountOfTokens,
		uint256 amountOfETH
	);

	YourToken public yourToken;

	constructor(address tokenAddress) {
		yourToken = YourToken(tokenAddress);
	}

	// ToDo: create a payable buyTokens() function:
	function buyTokens() public payable {
		require(msg.value > 0, "Send ETH to buy tokens");

		uint256 amountToBuy = msg.value * tokensPerEth;
		uint256 vendorBalance = yourToken.balanceOf(address(this));
		require(
			vendorBalance >= amountToBuy,
			"Vendor contract has insufficient tokens"
		);

		yourToken.transfer(msg.sender, amountToBuy);
		emit BuyTokens(msg.sender, msg.value, amountToBuy);
	}

	// ToDo: create a withdraw() function that lets the owner withdraw ETH
	function sellTokens(uint256 amount) public {
		require(amount > 0, "Specify an amount of tokens to sell");
		uint256 allowance = yourToken.allowance(msg.sender, address(this));
		require(allowance >= amount, "Check the token allowance");

		uint256 ethToTransfer = amount / tokensPerEth;
		require(
			address(this).balance >= ethToTransfer,
			"Vendor contract has insufficient ETH"
		);

		yourToken.transferFrom(msg.sender, address(this), amount);
		payable(msg.sender).transfer(ethToTransfer);

		emit SellTokens(msg.sender, amount, ethToTransfer);
	}

	// ToDo: create a sellTokens(uint256 _amount) function:
	function withdraw() public onlyOwner {
		uint256 contractBalance = address(this).balance;
		require(contractBalance > 0, "No ETH to withdraw");

		payable(owner()).transfer(contractBalance);
	}
}
