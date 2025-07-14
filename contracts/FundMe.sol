// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import { PriceConverter } from "./PriceConverter.sol";

// 426,732
// 406,390
// 394,372
contract FundMe {
    using PriceConverter for uint;

    uint public constant MINIMUM_USD = 5e18;
    address[] funders;
    mapping(address funder => uint amountFunded) public addressToAmoundFunded;

    address public immutable i_owner;
    constructor() {
        i_owner = msg.sender;
    }

    function fund() public payable {
        require(msg.value.getConversionRate() >= MINIMUM_USD, "didn't send enough ETH");
        funders.push(msg.sender);
        addressToAmoundFunded[msg.sender] += msg.value;
    }

    function withdraw() public onlyOwner {
        for (uint funderIndex = 0; funderIndex < funders.length; funderIndex++) 
        {
            addressToAmoundFunded[funders[funderIndex]] = 0;
        }
        funders = new address[](0);

        // // transfer
        // payable(msg.sender).transfer(address(this).balance);

        // // send
        // bool isSendSuccess = payable(msg.sender).send(address(this).balance);
        // require(isSendSuccess, "Send Failed");

        // call
        (bool isCallSuccess, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(isCallSuccess, "Call Failed");
    }

    modifier onlyOwner() {
        require(msg.sender == i_owner, "Sender is not owner");
        _;
    }

    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    }
}