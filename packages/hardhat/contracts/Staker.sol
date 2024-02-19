// SPDX-License-Identifier: MIT
pragma solidity 0.8.4; //Do not change the solidity version as it negativly impacts submission grading

import "hardhat/console.sol";
import "./ExampleExternalContract.sol";

contract Staker {
	ExampleExternalContract public exampleExternalContract;

	mapping(address => uint256) public balances;

	uint256 public threshold = 1 ether;

	event Stake(address indexed from, uint256 value);

	modifier stakeNotCompleted() {
		bool completed = exampleExternalContract.completed();
		require(!completed, "staking process already completed");
		_;
	}

  modifier deadlineReached( bool requireReached ) {
    uint timeRemaining = timeLeft();
    if ( requireReached ) {
      require( timeRemaining == 0, "deadline not reached" );
    } else {
      require( timeRemaining > 0, "deadline reached" );
    }
    _;
  }

	constructor(address exampleExternalContractAddress) {
		exampleExternalContract = ExampleExternalContract(
			exampleExternalContractAddress
		);
	}

	// Collect funds in a payable `stake()` function and track individual `balances` with a mapping:
	// (Make sure to add a `Stake(address,uint256)` event and emit it for the frontend `All Stakings` tab to display)
	// the instructions say to use the receive() function...
	// where should I add this function?
	// answer: at the end of the contract
	//

	// Add a `isStaked()` view function to check if an address has staked funds
	function isStaked(address _address) public view returns (bool) {
		console.log("Is staked function called");
		return balances[_address] > 0;
	}

	// Add a `thresholdReached()` view function to check if the staking threshold was reached
	function thresholdReached() public view returns (bool) {
		console.log("Threshold reached function called");
		return address(this).balance >= threshold;
	}

	// After some `deadline` allow anyone to call an `execute()` function
	// If the deadline has passed and the threshold is met, it should call `exampleExternalContract.complete{value: address(this).balance}()`
	uint256 public deadline = block.timestamp + 30 seconds;
	bool public openForWithdraw;
	bool public executed;



	// the execute function should call the complete function of the exampleExternalContract
	// the execute function should only be called after the deadline
	// the execute function should only be called if the threshold is reached
	function execute() public stakeNotCompleted deadlineReached(false) {
		console.log("Execute function called");
		require(block.timestamp >= deadline, "Deadline not reached");
		require(address(this).balance >= threshold, "Threshold not reached");
		exampleExternalContract.complete{ value: address(this).balance }();
		executed = true;
	}

	function stake() public payable stakeNotCompleted deadlineReached(false) {
		balances[msg.sender] += msg.value;

		if (balances[msg.sender] >= threshold) {
			console.log("Threshold reached");
		}
		// Emit the Stake event
		emit Stake(msg.sender, msg.value);
	}

	// If the `threshold` was not met, allow everyone to call a `withdraw()` function to withdraw their balance
	function withdraw() public stakeNotCompleted deadlineReached(true) {
		console.log("Withdraw function called");
		require(block.timestamp >= deadline, "Deadline not reached");
		require(address(this).balance < threshold, "Threshold reached");
		uint256 amount = balances[msg.sender];
		balances[msg.sender] = 0;
		payable(msg.sender).transfer(amount);
	}

	// Add a `timeLeft()` view function that returns the time left before the deadline for the frontend
	function timeLeft() public view returns (uint256 timeleft) {
		console.log("Time left function called");
		if (block.timestamp >= deadline) {
			return 0;
		} else {
			return deadline - block.timestamp;
		}
	}

}
