pragma solidity >=0.8.0 <0.9.0;
//SPDX-License-Identifier: MIT

import 'hardhat/console.sol';
import './ExampleExternalContract.sol';

contract Staker {
  ExampleExternalContract public exampleExternalContract;

  event Stake(address, uint256);
  event Received(address, uint);

  uint256 public constant threshold = 1 ether;
  uint256 public deadline = block.timestamp + 72 hours;
  bool public openForWithdraw;
  mapping(address => uint256) public balances;

  constructor(address exampleExternalContractAddress) {
    exampleExternalContract = ExampleExternalContract(exampleExternalContractAddress);
  }

  // TODO: Collect funds in a payable `stake()` function and track individual `balances` with a mapping:
  //  ( make sure to add a `Stake(address,uint256)` event and emit it for the frontend <List/> display )
  function stake() public payable {
    balances[msg.sender] += msg.value;
    emit Stake(msg.sender, msg.value);
  }

  // TODO: After some `deadline` allow anyone to call an `execute()` function
  //  It should call `exampleExternalContract.complete{value: address(this).balance}()` to send all the value

  function execute() public notCompleted {
    require(timeLeft() == 0, 'not yet timeout');

    if (address(this).balance >= threshold) {
      exampleExternalContract.complete{value: address(this).balance}();
    } else {
      openForWithdraw = true;
    }
  }

  // TODO: if the `threshold` was not met, allow everyone to call a `withdraw()` function
  function withdraw() public {
    require(openForWithdraw, 'Withdraw not allowed');
    require(balances[msg.sender] > 0, 'nothing to withdraw');

    uint256 balance = balances[msg.sender];

    payable(msg.sender).transfer(balance);
    balances[msg.sender] = 0;
  }

  // TODO: Add a `timeLeft()` view function that returns the time left before the deadline for the frontend
  function timeLeft() public view returns (uint256) {
    // avoid underflow
    if (block.timestamp >= deadline) return 0;
    else return deadline - block.timestamp;
  }

  // TODO: Add the `receive()` special function that receives eth and calls stake()
  receive() external payable notCompleted {
    emit Received(msg.sender, msg.value);
  }

  modifier notCompleted() {
    require(!exampleExternalContract.completed(), 'not completed');
    _;
  }
}
