// SPDX-License-Identifier: MIT
pragma solidity >0.4.0 <= 0.9.0;

import "./ERToken.sol";

  contract ICO {
    ERToken public token;
    address public owner;
    uint256 public rate;
    uint256 public end;
    uint256 public tokensSold;

    event TokensPurchased(address indexed buyer, uint256 amount);
    event Ended(uint256 totalTokensSold);

    modifier onlyOwner() {
        require(msg.sender == owner, "You are not the owner");
        _;
    }

    constructor(uint256 _rate, uint256 _duration, address _tokenAddress) {
        owner = msg.sender;
        rate = _rate;
        end = block.timestamp + _duration;
        token = ERToken(_tokenAddress);
    }

    function buyTokens(uint256 tokenAmount) public payable {
        require(block.timestamp < end, "ICO has ended");
        uint256 requiredWei = tokenAmount / rate;
        require(msg.value >= requiredWei, "Not enough ETH to buy tokens");
        require(token.balanceOf(owner) >= tokenAmount, "Not enough tokens available");

        token.transfer(msg.sender, tokenAmount);
        tokensSold += tokenAmount;

        emit TokensPurchased(msg.sender, tokenAmount);

        // Trả lại số dư ETH thừa nếu có
        if (msg.value > requiredWei) {
            payable(msg.sender).transfer(msg.value - requiredWei);
        }
    }

    function endICO() public onlyOwner {
        require(block.timestamp >= end, "ICO has not ended yet");
        uint256 remainingTokens = token.balanceOf(address(this));
        token.transfer(owner, remainingTokens);

        emit Ended(tokensSold);
    }

    function withdraw() public onlyOwner {
        payable(owner).transfer(address(this).balance);
    }
}
