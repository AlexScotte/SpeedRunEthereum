pragma solidity >=0.8.0 <0.9.0;
// SPDX-License-Identifier: MIT

import '@openzeppelin/contracts/access/Ownable.sol';
import './YourToken.sol';

import 'hardhat/console.sol';

contract Vendor is Ownable {
  YourToken public yourToken;

  uint256 public constant tokensPerEth = 100;
  event BuyTokens(address buyer, uint256 amountOfEth, uint256 amountOfTokens);
  event SellTokens(address seller, uint256 amountOfEth, uint256 amountOfTokens);

  constructor(address tokenAddress) {
    yourToken = YourToken(tokenAddress);
  }

  // ToDo: create a payable buyTokens() function:
  function buyTokens() public payable {
    uint256 amountOfTokens = msg.value * tokensPerEth;
    yourToken.transfer(msg.sender, amountOfTokens);
    emit BuyTokens(msg.sender, msg.value, amountOfTokens);
  }

  // ToDo: create a withdraw() function that lets the owner withdraw ETH
  function withdraw() public onlyOwner {
    require(address(this).balance > 0, 'nothing to withdraw');
    payable(msg.sender).transfer(address(this).balance);
  }

  // ToDo: create a sellTokens() function:
  function sellTokens(uint256 amountOfToken) public {
    require(yourToken.balanceOf(msg.sender) >= amountOfToken, 'not enough token for this user');

    yourToken.transferFrom(msg.sender, address(this), amountOfToken);

    payable(msg.sender).transfer(amountOfToken / tokensPerEth);
    emit SellTokens(msg.sender, amountOfToken / tokensPerEth, amountOfToken);
  }
}
